import AVFoundation
import Accessibility
import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

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

    /// Per-announcement retry budget when VoiceOver reports `wasSuccessful = false`
    /// (the announcement was preempted before it could be fully spoken).
    private static let voMaxRetries: Int = 1

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

    /// FIFO of attributed announcements waiting to be posted via
    /// ``AccessibilityNotification.Announcement``. iOS priorities alone do
    /// **not** preserve message order — multiple `.high` posts in flight will
    /// preempt each other, dropping all but the most recent. We serialize
    /// posts ourselves and only advance after VoiceOver fires the
    /// `announcementDidFinishNotification` for the in-flight item.
    private struct PendingVOAnnouncement {
        var attributed: AttributedString
        var retriesLeft: Int
    }
    private var voQueue: [PendingVOAnnouncement] = []
    private var voInFlight: PendingVOAnnouncement?
    private var voTimeoutTimer: Timer?

    /// Whether we've configured the audio session this app launch. iOS only.
    private var audioSessionConfigured = false

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
        #endif
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
    /// - Parameter queue: when `true`, the utterance is queued (`.low` priority
    ///   under VoiceOver). When `false`, it interrupts other UI text.
    func speakUI(_ text: String, queue: Bool = false) {
        enqueue(text, channel: .ui, interrupting: !queue)
    }

    /// Stop all current and pending speech immediately.
    func stop() {
        utteranceToken &+= 1
        activeChannel = nil
        activeText = ""
        queue.removeAll()
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

        let now = Date()
        if text == lastSpokenText, now.timeIntervalSince(lastSpokenAt) < Self.dedupWindow {
            return
        }
        lastSpokenText = text
        lastSpokenAt = now

        if isVoiceOverRunning {
            postVoiceOverAnnouncement(text, channel: channel, interrupting: interrupting)
        } else {
            postSynthesizerSpeech(text, channel: channel, interrupting: interrupting)
        }
    }

    // MARK: - VoiceOver path

    /// Builds an attributed announcement with the right priority for the
    /// channel and adds it to our serialized queue. The queue is drained by
    /// ``pumpVoiceOverQueue()`` whenever a previous announcement finishes
    /// (success or failure), so messages are heard in order rather than
    /// preempting each other when posted in rapid succession.
    private func postVoiceOverAnnouncement(_ text: String, channel: Channel, interrupting: Bool) {
        var attributed = AttributedString(text)
        switch (channel, interrupting) {
        case (.announcement, _):
            attributed.accessibilitySpeechAnnouncementPriority = .high
        case (.ui, true):
            attributed.accessibilitySpeechAnnouncementPriority = .default
        case (.ui, false):
            attributed.accessibilitySpeechAnnouncementPriority = .low
        }

        voQueue.append(PendingVOAnnouncement(attributed: attributed, retriesLeft: Self.voMaxRetries))
        pumpVoiceOverQueue()
    }

    /// Post the next queued announcement if nothing is currently in flight.
    /// VoiceOver will fire ``UIAccessibility/announcementDidFinishNotification``
    /// when it's done with the post; that drives the next call.
    private func pumpVoiceOverQueue() {
        guard voInFlight == nil, !voQueue.isEmpty else { return }
        let next = voQueue.removeFirst()
        voInFlight = next
        scheduleVoiceOverTimeout(for: next.attributed)
        // Posting via async lets any in-progress focus-change accessibility
        // event drain first; same-tick posts are sometimes swallowed.
        let attributed = next.attributed
        DispatchQueue.main.async {
            AccessibilityNotification.Announcement(attributed).post()
        }
    }

    /// Safety net: if VoiceOver never fires the finish notification (the app
    /// went to the background mid-utterance, the user toggled VoiceOver off,
    /// etc.), advance the queue anyway so it can never wedge.
    private func scheduleVoiceOverTimeout(for attributed: AttributedString) {
        cancelVoiceOverTimeout()
        let length = String(attributed.characters).count
        let estimated = max(Self.fallbackMinSeconds,
                            Double(length) * Self.fallbackPerCharSeconds)
        voTimeoutTimer = Timer.scheduledTimer(withTimeInterval: estimated, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.voInFlight != nil else { return }
                self.voInFlight = nil
                self.pumpVoiceOverQueue()
            }
        }
    }

    private func cancelVoiceOverTimeout() {
        voTimeoutTimer?.invalidate()
        voTimeoutTimer = nil
    }

    /// VoiceOver tells us when our most recent announcement is done speaking.
    /// `wasSuccessful = false` means VoiceOver started but was interrupted
    /// before finishing; we requeue the same announcement (up to
    /// ``voMaxRetries``) so it isn't lost.
    @objc private nonisolated func voiceOverAnnouncementDidFinish(_ note: Notification) {
        let userInfo = note.userInfo
        let wasSuccessful: Bool
        #if os(iOS)
        wasSuccessful = (userInfo?[UIAccessibility.announcementWasSuccessfulUserInfoKey] as? Bool) ?? true
        #else
        wasSuccessful = true
        #endif
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard var inflight = self.voInFlight else { return }
            self.cancelVoiceOverTimeout()
            if !wasSuccessful, inflight.retriesLeft > 0 {
                inflight.retriesLeft -= 1
                self.voQueue.insert(inflight, at: 0)
            }
            self.voInFlight = nil
            self.pumpVoiceOverQueue()
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
        if synth.isSpeaking || synth.isPaused {
            synth.stopSpeaking(at: .immediate)
        }
        utteranceToken &+= 1
        let token = utteranceToken
        activeChannel = channel
        activeText = text

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        synth.speak(utterance)

        scheduleFallback(for: text, token: token)
    }

    private func advanceQueue() {
        cancelFallbackTimer()
        activeChannel = nil
        activeText = ""

        guard let next = queue.first else {
            deactivateAudioSession()
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

    /// AVSpeechSynthesizer activates the session implicitly but never
    /// deactivates it, leaving other audio ducked indefinitely. We deactivate
    /// once our queue drains so background apps recover their volume.
    private func deactivateAudioSession() {
        #if os(iOS)
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
        // We only cancel deliberately (replacement utterance) or via stop().
        // In the replacement case, the new utterance is already in flight; in
        // the stop() case the queue is already empty — either way, no work.
    }
}
