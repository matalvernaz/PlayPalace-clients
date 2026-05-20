import AVFoundation
import Accessibility
import Foundation
import os

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

private let speechLog = Logger(subsystem: "ca.cobd.playpalace.ios", category: "speech")

/// Manages spoken output for the client, routing to VoiceOver when present and
/// to ``AVSpeechSynthesizer`` otherwise.
///
/// Speech is split into two channels:
///
/// - **Announcement** — important game events (turn changes, wins, errors).
///   Uses `.high` priority when VoiceOver is running, jumps the queue when it
///   isn't. These should rarely be lost.
/// - **UI** — focus and menu chatter. Interruptible by the next UI utterance,
///   yields to in-flight announcements.
///
/// The legacy ``speak(_:interrupt:)`` API is preserved for existing callers and
/// maps to the UI channel.
@MainActor
final class SpeechManager: NSObject, ObservableObject {

    // MARK: - Tunables

    /// Identical text within this window is suppressed; VoiceOver's live-region
    /// pipeline can re-fire the same announcement multiple times in rapid
    /// succession and we don't want to repeat ourselves.
    private static let dedupWindow: TimeInterval = 0.7

    /// Default rate for ``AVSpeechSynthesizer``. ``AVSpeechUtteranceDefaultSpeechRate``
    /// (~0.5) is Apple's "normal" pace; we expose ``setRate(_:)`` for future use.
    private static let defaultRate: Float = AVSpeechUtteranceDefaultSpeechRate

    /// ``AVSpeechSynthesizer`` occasionally drops `didFinish` callbacks
    /// (especially when interrupted by phone audio). This is the per-character
    /// budget for our fallback timer; tuned generously so we never cut speech
    /// short.
    private static let fallbackPerCharSeconds: TimeInterval = 0.12

    /// Lower bound for the fallback timer regardless of text length.
    private static let fallbackMinSeconds: TimeInterval = 4.0

    // MARK: - Speech channel

    enum Channel {
        case announcement
        case ui
    }

    // MARK: - State

    private let synth = AVSpeechSynthesizer()

    private var lastSpokenText: String = ""
    private var lastSpokenAt: Date = .distantPast

    private var rate: Float = SpeechManager.defaultRate

    /// Monotonic token used to invalidate stale delegate / fallback callbacks
    /// after we cancel speech.
    private var utteranceToken: Int = 0
    private var activeChannel: Channel?
    private var activeText: String = ""
    private var fallbackTimer: Timer?

    /// Pending utterances for the AVSpeechSynthesizer path.
    private var queue: [(channel: Channel, text: String)] = []

    /// Utterance waiting to be spoken once the synthesizer finishes cancelling
    /// the previous one. AVSpeechSynthesizer's `stopSpeaking(at: .immediate)`
    /// is asynchronous: if we call `speak()` before the cancel has propagated,
    /// the new utterance is **appended** to the synth's internal queue and the
    /// user hears the old text in full before the new one starts — the exact
    /// symptom reported by rapid menu navigation. We defer the new speak
    /// until `didCancel` fires (or a short safety timeout, in case the
    /// delegate misses).
    private struct PendingSynthStart {
        let text: String
        let channel: Channel
        let token: Int
    }
    private var pendingStart: PendingSynthStart?
    private var pendingStartTimeoutTimer: Timer?

    /// Safety-net delay for the pending-start path. Long enough that
    /// `didCancel` reliably wins in the common case (typically 10–30 ms),
    /// short enough that the user can't notice it as lag.
    private static let pendingStartTimeout: TimeInterval = 0.25

    /// FIFO of attributed announcements waiting to be posted. iOS priorities
    /// alone do **not** preserve message order — multiple `.high` posts in
    /// flight will preempt each other, dropping all but the most recent. We
    /// serialize posts ourselves and only advance after VoiceOver fires the
    /// `announcementDidFinishNotification` for the in-flight item.
    ///
    /// Each entry carries a UUID so the timeout closure and the finish-
    /// notification handler can ignore stale callbacks for an item that has
    /// already been advanced past — without this, a late `didFinish` for the
    /// previous item could corrupt the state of the new in-flight item.
    private struct PendingVOAnnouncement {
        let id: UUID = UUID()
        var channel: Channel
        var text: String
    }
    private var voQueue: [PendingVOAnnouncement] = []
    private var voInFlight: PendingVOAnnouncement?
    private var voTimeoutTimer: Timer?

    /// Whether we've configured the audio session this app launch. iOS only.
    private var audioSessionConfigured = false

    /// Pending "deactivate the audio session" task. Speaking utterance N
    /// then immediately enqueuing N+1 used to pay an activate→deactivate→
    /// activate cycle around AVSpeechSynthesizer's idle gap, and that
    /// cycle adds noticeable cold-start latency to every flick because
    /// AVSpeechSynthesizer needs to re-warm the voice each time. Instead
    /// we defer the deactivate by a few seconds so a follow-up utterance
    /// keeps the session warm.
    private var deactivateTimer: Timer?

    private static let deactivateDelay: TimeInterval = 10.0

    /// When true, all speech is routed through ``AVSpeechSynthesizer`` even
    /// while VoiceOver is running. Set by the game touch view while it holds
    /// accessibility focus, because VoiceOver's focus-element chatter on a
    /// view with ``UIAccessibilityTraits/allowsDirectInteraction`` preempts
    /// our ``UIAccessibility/post(notification:argument:)`` announcements,
    /// leaving the user with no audible response to their gestures. The
    /// synth path with `prefersAssistiveTechnologySettings = true` adopts
    /// the VoiceOver voice so the user still hears the same voice they
    /// expect, while sidestepping VO's announcement queue entirely.
    var forceSelfVoicing: Bool = false

    // MARK: - Public API

    override init() {
        super.init()
        synth.delegate = self
        #if os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverAnnouncementDidFinish(_:)),
            name: UIAccessibility.announcementDidFinishNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverStatusDidChange(_:)),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
        #endif
    }

    /// Whether anything is currently speaking or queued. Used by callers
    /// that want to avoid stomping on in-flight speech (e.g. the idle
    /// timer that would otherwise interrupt a long server narration just
    /// to re-announce the current menu item).
    var isSpeaking: Bool {
        voInFlight != nil
            || !voQueue.isEmpty
            || activeChannel != nil
            || !queue.isEmpty
            || pendingStart != nil
    }

    /// Legacy entry point — preserved so existing call sites keep working.
    /// Maps to the UI channel; ``interrupt: true`` cancels in-flight UI but
    /// yields to announcements.
    func speak(_ text: String, interrupt: Bool = true) {
        speakUI(text, queue: !interrupt)
    }

    /// Speak an important game event. Cuts in front of UI chatter.
    func speakAnnouncement(_ text: String) {
        enqueue(text, channel: .announcement, interrupting: true)
    }

    /// Speak UI / focus text.
    /// - Parameter queue: when `true`, the utterance waits its turn in the
    ///   queue. When `false`, queued UI text is dropped so this speaks next.
    func speakUI(_ text: String, queue: Bool = false) {
        enqueue(text, channel: .ui, interrupting: !queue)
    }

    /// Speak only when self-voicing — VoiceOver users skip this. Use for
    /// transition cues ("Chat opened.", "Help opened.") that VoiceOver
    /// already covers by auto-focusing the new screen's title. Without the
    /// guard we'd double-announce on every sheet open. When
    /// ``forceSelfVoicing`` is on we *are* the speech source, so VoiceOver
    /// isn't doing the auto-focus-title readback for us and the cue would
    /// otherwise be lost.
    func speakTransition(_ text: String) {
        guard !isVoiceOverRunning || forceSelfVoicing else { return }
        speakUI(text, queue: true)
    }

    /// Stop all current and pending speech immediately.
    func stop() {
        utteranceToken &+= 1
        activeChannel = nil
        activeText = ""
        queue.removeAll()
        pendingStart = nil
        cancelPendingStartTimeout()
        cancelFallbackTimer()
        voQueue.removeAll()
        voInFlight = nil
        cancelVoiceOverTimeout()
        if synth.isSpeaking || synth.isPaused {
            synth.stopSpeaking(at: .immediate)
        }
        deactivateAudioSession()
    }

    /// Adjust the rate for the ``AVSpeechSynthesizer`` path. VoiceOver speech
    /// rate is controlled by the user's system settings and we never override
    /// it.
    func setRate(_ newRate: Float) {
        rate = max(AVSpeechUtteranceMinimumSpeechRate,
                   min(AVSpeechUtteranceMaximumSpeechRate, newRate))
    }

    // MARK: - Routing

    private func enqueue(_ text: String, channel: Channel, interrupting: Bool) {
        guard !text.isEmpty else { return }

        // Dedup applies only to the UI channel — rapid menu navigation can
        // re-emit the same item text within a few hundred ms and we want
        // to collapse that. Announcements carry server-authoritative game
        // events (turn changes, dice results, scoring) that must never be
        // silently dropped, even when identical to the previous one — a
        // bot rolling the same number twice in a row would otherwise
        // produce one announcement instead of two.
        if channel == .ui {
            let now = Date()
            if text == lastSpokenText, now.timeIntervalSince(lastSpokenAt) < Self.dedupWindow {
                return
            }
            lastSpokenText = text
            lastSpokenAt = now
        }

        let voOn = isVoiceOverRunning
        let useVOPath = voOn && !forceSelfVoicing
        speechLog.debug("enqueue voOn=\(voOn, privacy: .public) forceSelfVoicing=\(self.forceSelfVoicing, privacy: .public) channel=\(String(describing: channel), privacy: .public) interrupting=\(interrupting, privacy: .public) text=\(text, privacy: .public)")
        if useVOPath {
            postVoiceOverAnnouncement(text, channel: channel, interrupting: interrupting)
        } else {
            postSynthesizerSpeech(text, channel: channel, interrupting: interrupting)
        }
    }

    // MARK: - VoiceOver path

    /// Builds an attributed announcement and adds it to our serialized queue.
    ///
    /// Apple's priority field is treated as advisory only: `.high` for
    /// game-event announcements, `.default` for everything else. We do not
    /// use `.low` — Apple drops `.low` announcements when VoiceOver is busy
    /// with focus chatter or system speech, which is exactly when our
    /// server-pushed game speech needs to land. Ordering is handled by the
    /// local FIFO, not by Apple's priority.
    ///
    /// When `interrupting` is true on a UI announcement, queued UI items are
    /// dropped so that rapid menu navigation doesn't backlog the queue.
    /// Announcements always win over UI: queued UI is dropped to make way.
    private func postVoiceOverAnnouncement(_ text: String, channel: Channel, interrupting: Bool) {
        switch channel {
        case .announcement:
            voQueue.removeAll(where: { $0.channel == .ui })
        case .ui:
            if interrupting {
                voQueue.removeAll(where: { $0.channel == .ui })
            }
        }

        let pending = PendingVOAnnouncement(channel: channel, text: text)
        voQueue.append(pending)
        pumpVoiceOverQueue()
    }

    /// Post the next queued announcement if nothing is currently in flight.
    /// VoiceOver will fire ``UIAccessibility/announcementDidFinishNotification``
    /// when it's done with the post; that drives the next call.
    ///
    /// We post synchronously on the main actor. A previous version dispatched
    /// the post via ``DispatchQueue/main/async`` to let pending focus-change
    /// events drain first, but that opened a race where a stale `didFinish`
    /// notification could consume the in-flight slot before the post had
    /// even occurred — causing announcements to be silently skipped.
    ///
    /// On iOS we post via ``UIAccessibility/post(notification:argument:)``
    /// rather than ``AccessibilityNotification/Announcement`` — the SwiftUI
    /// API silently no-ops in several situations on iOS (notably when the
    /// active accessibility element carries ``UIAccessibilityTraits/allowsDirectInteraction``,
    /// which is exactly the trait the game touch view uses). The UIKit API
    /// is the documented reliable path.
    private func pumpVoiceOverQueue() {
        guard voInFlight == nil, !voQueue.isEmpty else { return }
        let next = voQueue.removeFirst()
        voInFlight = next
        scheduleVoiceOverTimeout(for: next.id)
        speechLog.debug("VO post text=\(next.text, privacy: .public) channel=\(String(describing: next.channel), privacy: .public)")
        #if os(iOS)
        // Apple's documented priority values are integer constants — high=75,
        // default=50. The Swift-shaped `UIAccessibilityPriority` symbol
        // collides with the `Accessibility`-framework enum we also import for
        // AttributedString accessors, so we pass NSNumber(Int) directly to
        // avoid the resolution ambiguity.
        let priorityValue = next.channel == .announcement ? 75 : 50
        let attributed = NSMutableAttributedString(string: next.text)
        attributed.addAttribute(
            .accessibilitySpeechAnnouncementPriority,
            value: NSNumber(value: priorityValue),
            range: NSRange(location: 0, length: attributed.length)
        )
        UIAccessibility.post(notification: .announcement, argument: attributed)
        #else
        var attributed = AttributedString(next.text)
        switch next.channel {
        case .announcement:
            attributed.accessibilitySpeechAnnouncementPriority = .high
        case .ui:
            attributed.accessibilitySpeechAnnouncementPriority = .default
        }
        AccessibilityNotification.Announcement(attributed).post()
        #endif
    }

    /// Safety net: if VoiceOver never fires the finish notification (app
    /// backgrounded mid-utterance, VoiceOver toggled off, etc.), advance the
    /// queue anyway so it can never wedge. Gated on the announcement's UUID
    /// so a stale timer can't stomp on a newer in-flight item.
    private func scheduleVoiceOverTimeout(for id: UUID) {
        cancelVoiceOverTimeout()
        let length = voInFlight.map { $0.text.count } ?? 0
        let estimated = max(Self.fallbackMinSeconds,
                            Double(length) * Self.fallbackPerCharSeconds)
        voTimeoutTimer = Timer.scheduledTimer(withTimeInterval: estimated, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.voInFlight?.id == id else { return }
                self.voInFlight = nil
                self.pumpVoiceOverQueue()
            }
        }
    }

    private func cancelVoiceOverTimeout() {
        voTimeoutTimer?.invalidate()
        voTimeoutTimer = nil
    }

    /// VoiceOver tells us when an announcement is done speaking. Use the
    /// `announcementStringValueUserInfoKey` payload to confirm the finish
    /// belongs to our current in-flight item rather than a previous one we
    /// already timed out — without that check, a late finish could clobber
    /// the new in-flight item's state.
    ///
    /// We deliberately do **not** retry on `wasSuccessful = false`. VoiceOver
    /// reports failure when the announcement was interrupted, which almost
    /// always means the user touched the screen or a higher-priority event
    /// arrived. Re-posting was the cause of the "speech announces twice" bug.
    @objc private nonisolated func voiceOverAnnouncementDidFinish(_ note: Notification) {
        let finishedText: String?
        let wasSuccessful: Bool?
        #if os(iOS)
        finishedText = note.userInfo?[UIAccessibility.announcementStringValueUserInfoKey] as? String
        wasSuccessful = (note.userInfo?[UIAccessibility.announcementWasSuccessfulUserInfoKey] as? Bool)
        #else
        finishedText = nil
        wasSuccessful = nil
        #endif
        speechLog.debug("VO didFinish text=\(finishedText ?? "<nil>", privacy: .public) success=\(wasSuccessful.map { String($0) } ?? "<nil>", privacy: .public)")
        Task { @MainActor [weak self] in
            guard let self, let inflight = self.voInFlight else { return }
            if let finishedText, !Self.announcementsMatch(finishedText, inflight.text) {
                // Stale didFinish for a previously-timed-out item; ignore so
                // we don't pop the new in-flight item prematurely.
                return
            }
            self.cancelVoiceOverTimeout()
            self.voInFlight = nil
            self.pumpVoiceOverQueue()
        }
    }

    /// VoiceOver normalises text before reporting it back via
    /// ``announcementStringValueUserInfoKey`` — punctuation, casing, and
    /// some abbreviations (e.g. "1st" → "first") can differ from what we
    /// posted. A strict equality check would mistake the same finish for a
    /// stale one and wedge the queue for a full timeout cycle. Compare a
    /// normalised, alphanumeric prefix so we still reject obviously-stale
    /// finishes but tolerate iOS's text munging.
    private static func announcementsMatch(_ a: String, _ b: String) -> Bool {
        let normalize: (String) -> String = { s in
            String(s.lowercased().filter { $0.isLetter || $0.isNumber }.prefix(64))
        }
        let na = normalize(a)
        let nb = normalize(b)
        if na.isEmpty || nb.isEmpty {
            // No usable signal — assume it matches rather than wedge.
            return true
        }
        return na == nb || na.hasPrefix(nb) || nb.hasPrefix(na)
    }

    /// VoiceOver toggled on or off mid-session. Both queues are now stale —
    /// the synth queue can't reach VO and any pending VO posts won't ever
    /// fire didFinish — so tear everything down and let the next enqueue
    /// land on whichever path is currently active.
    @objc private nonisolated func voiceOverStatusDidChange(_ note: Notification) {
        Task { @MainActor [weak self] in
            self?.stop()
        }
    }

    // MARK: - AVSpeechSynthesizer path

    private func postSynthesizerSpeech(_ text: String, channel: Channel, interrupting: Bool) {
        configureAudioSessionIfNeeded()

        switch channel {
        case .announcement:
            // Announcements always win. Drop pending UI, cancel current, speak now.
            queue.removeAll(where: { $0.channel == .ui })
            startSpeaking(text: text, channel: .announcement)

        case .ui:
            if activeChannel == .announcement {
                // Don't step on an in-flight announcement; queue or drop.
                if !interrupting {
                    queue.append((.ui, text))
                }
                return
            }
            if interrupting {
                queue.removeAll(where: { $0.channel == .ui })
                startSpeaking(text: text, channel: .ui)
            } else if activeChannel == nil {
                startSpeaking(text: text, channel: .ui)
            } else {
                queue.append((.ui, text))
            }
        }
    }

    private func startSpeaking(text: String, channel: Channel) {
        utteranceToken &+= 1
        let token = utteranceToken
        activeChannel = channel
        activeText = text

        // If something is already speaking — or we're mid-cancel from a
        // previous startSpeaking — hand the new utterance to the delegate
        // path: stash it as pendingStart and wait for didCancel before
        // calling speak(). Calling speak() synchronously here causes
        // AVSpeechSynthesizer to append it to the post-cancel queue, which
        // is why rapid menu navigation used to feel like every item read to
        // completion before the next one started. The `pendingStart` arm
        // covers a second startSpeaking arriving while the synth is still
        // winding down from the previous stop (its `isSpeaking` may already
        // read false even though the cancel hasn't propagated).
        if synth.isSpeaking || synth.isPaused || pendingStart != nil {
            pendingStart = PendingSynthStart(text: text, channel: channel, token: token)
            synth.stopSpeaking(at: .immediate)
            schedulePendingStartTimeout(for: token)
            return
        }

        pendingStart = nil
        cancelPendingStartTimeout()
        speakUtterance(text: text, token: token)
    }

    /// Hand an utterance to the synthesizer and arm the per-utterance
    /// safety-net fallback timer.
    ///
    /// `prefersAssistiveTechnologySettings = true` is the Apple-documented
    /// way to make AVSpeechSynthesizer adopt VoiceOver's selected voice,
    /// rate, and pitch when VoiceOver is running (WWDC 2020 session 10022,
    /// "Create a seamless speech experience in your apps"). It's why we
    /// also stop overriding `utterance.rate` when VO is on — VO's user-
    /// configured rate wins. Without this flag, blind testers correctly
    /// observe that our self-voicing speech doesn't sound like their VO
    /// voice. When VO is off the flag falls back to Spoken Content
    /// settings, so the non-VO path is also better behaved.
    private func speakUtterance(text: String, token: Int) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.prefersAssistiveTechnologySettings = true
        if !isVoiceOverRunning {
            utterance.rate = rate
        }
        synth.speak(utterance)
        scheduleFallback(for: text, token: token)
    }

    /// If `didCancel` doesn't reach us within the timeout window (rare —
    /// happens when an audio-session change or backgrounding swallows the
    /// callback), force the pending utterance to start anyway so the user
    /// isn't left in silence.
    private func schedulePendingStartTimeout(for token: Int) {
        cancelPendingStartTimeout()
        pendingStartTimeoutTimer = Timer.scheduledTimer(
            withTimeInterval: Self.pendingStartTimeout, repeats: false
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.flushPendingStart(expectedToken: token)
            }
        }
    }

    private func cancelPendingStartTimeout() {
        pendingStartTimeoutTimer?.invalidate()
        pendingStartTimeoutTimer = nil
    }

    /// Start whatever's in `pendingStart`, but only if it's still the most
    /// recent intent (token-gated) so we never stomp on a stop() or a newer
    /// utterance request. Idempotent — safe to call from didCancel and the
    /// safety-net timer.
    private func flushPendingStart(expectedToken: Int) {
        guard let pending = pendingStart else { return }
        guard pending.token == utteranceToken else {
            pendingStart = nil
            cancelPendingStartTimeout()
            return
        }
        guard pending.token == expectedToken else { return }
        pendingStart = nil
        cancelPendingStartTimeout()
        speakUtterance(text: pending.text, token: pending.token)
    }

    private func advanceQueue() {
        cancelFallbackTimer()
        activeChannel = nil
        activeText = ""

        guard let next = queue.first else {
            scheduleDeactivate()
            return
        }
        queue.removeFirst()
        startSpeaking(text: next.text, channel: next.channel)
    }

    // MARK: - Fallback timer

    /// AVSpeechSynthesizer's `didFinish` is reliable but not guaranteed —
    /// audio interruptions and rare bugs can swallow it. We schedule a
    /// generous timeout based on text length so the queue can never deadlock.
    private func scheduleFallback(for text: String, token: Int) {
        cancelFallbackTimer()
        let estimated = max(Self.fallbackMinSeconds,
                            Double(text.count) * Self.fallbackPerCharSeconds)
        fallbackTimer = Timer.scheduledTimer(withTimeInterval: estimated, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard token == self.utteranceToken else { return }
                self.synth.stopSpeaking(at: .immediate)
                self.advanceQueue()
            }
        }
    }

    private func cancelFallbackTimer() {
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }

    // MARK: - Audio session (iOS only)

    /// Configure the shared audio session for speech that mixes with media
    /// (game music, podcasts in the background, etc.). We only touch this
    /// when we actually need to synthesize — VoiceOver routes through its own
    /// session.
    private func configureAudioSessionIfNeeded() {
        #if os(iOS)
        // If a deferred deactivation is in flight, cancel it — the user is
        // speaking again, the session must stay live.
        deactivateTimer?.invalidate()
        deactivateTimer = nil
        guard !audioSessionConfigured else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
            try session.setActive(true, options: [])
            audioSessionConfigured = true
        } catch {
            // Non-fatal: speech still works, but audio routing may be wonky.
        }
        #endif
    }

    /// Defer audio-session deactivation. If new speech arrives within the
    /// window, the timer is cancelled (see ``configureAudioSessionIfNeeded``)
    /// and we keep the session — and the synthesizer's voice cache — warm.
    private func scheduleDeactivate() {
        #if os(iOS)
        guard audioSessionConfigured else { return }
        deactivateTimer?.invalidate()
        deactivateTimer = Timer.scheduledTimer(
            withTimeInterval: Self.deactivateDelay, repeats: false
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.deactivateAudioSession()
            }
        }
        #endif
    }

    /// AVSpeechSynthesizer activates the session implicitly but never
    /// deactivates it, leaving other audio ducked indefinitely. We deactivate
    /// once our queue drains so background apps recover their volume.
    private func deactivateAudioSession() {
        #if os(iOS)
        deactivateTimer?.invalidate()
        deactivateTimer = nil
        guard audioSessionConfigured else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            audioSessionConfigured = false
        } catch {
            // Non-fatal.
        }
        #endif
    }

    // MARK: - Platform helpers

    private var isVoiceOverRunning: Bool {
        #if os(macOS)
        return NSWorkspace.shared.isVoiceOverEnabled
        #elseif os(iOS)
        return UIAccessibility.isVoiceOverRunning
        #else
        return false
        #endif
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechManager: AVSpeechSynthesizerDelegate {

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.advanceQueue()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       didCancel utterance: AVSpeechUtterance) {
        // We cancel deliberately in two cases: stop() (clears pendingStart),
        // and startSpeaking() when interrupting an in-flight utterance
        // (stashes the new text as pendingStart). In the latter case we want
        // to start the replacement *now* — calling synth.speak() before the
        // cancel had propagated would append the new utterance to the
        // synth's internal queue instead of preempting.
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let pending = self.pendingStart else { return }
            self.flushPendingStart(expectedToken: pending.token)
        }
    }
}
