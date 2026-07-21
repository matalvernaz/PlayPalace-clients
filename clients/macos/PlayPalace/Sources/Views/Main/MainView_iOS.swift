#if os(iOS)
import AVFoundation
import SwiftUI
import UIKit
import os

// MARK: - Main View

/// Diagnostic log for the VoiceOver direct-touch interaction mode. Stream with
/// Console.app or `log stream --predicate 'subsystem == "ca.cobd.playpalace.ios"
/// && category == "directtouch"'` (device tethered to a Mac) while running the
/// on-device VoiceOver experiment.
private let directTouchLog = Logger(subsystem: "ca.cobd.playpalace.ios", category: "directtouch")

/// The main game view for iOS.
/// Self-voicing audiogame pattern: handles all speech and touch directly.
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var gestureSettings = GestureSettings.load()
    @Environment(\.scenePhase) private var scenePhase
    @State private var wasBackgrounded = false
    @State private var showingChat = false
    @State private var showingControls = false
    @State private var showingHelp = false
    @State private var showingGestureSettings = false
    @State private var showingEventLog = false

    /// True while a surface that takes over input and speech sits on top of
    /// the game area (any sheet, the edit overlay, or the connect alert).
    private var modalSurfaceUp: Bool {
        showingChat || showingControls || showingHelp || showingEventLog
            || viewModel.isEditMode || viewModel.initialConnectFailed
    }

    var body: some View {
        // The game surface stays mounted while the edit overlay is up.
        // Unmounting it destroyed the GameTouchView, and the replacement
        // instance reset the VoiceOver interaction mode to navigation — a
        // server edit prompt mid-direct-play silently dumped the player out
        // of direct touch. Hidden + hit-test-disabled preserves the mode
        // across the round trip.
        ZStack {
            ZStack(alignment: .topTrailing) {
                DirectTouchGameView(
                    viewModel: viewModel,
                    gestureSettings: gestureSettings,
                    isSurfaceActive: !modalSurfaceUp,
                    onOpenChat: { showingChat = true },
                    onOpenControls: { showingControls = true },
                    onOpenHelp: { showingHelp = true },
                    onOpenEventLog: { showingEventLog = true }
                )
                // Leave the bottom safe area free of the direct-touch
                // view so the iPhone home-indicator gesture isn't
                // swallowed by `allowsDirectInteraction`. iOS routes
                // the system swipe-up via that strip; if our view
                // owns it, the user can't leave the app.
                .ignoresSafeArea(.container, edges: [.top, .horizontal])

                // Visible game state for low-vision players. Sits at the
                // top, doesn't consume touches — gestures still go to
                // the touch view underneath. Hidden from VoiceOver
                // because the same info is already spoken.
                VStack(spacing: 0) {
                    LowVisionStatusOverlay(viewModel: viewModel)
                    Spacer()
                }

                // Visible recovery affordance for sighted / low-vision
                // players, reachable regardless of the user's gesture
                // mappings. Hidden from VoiceOver: a second focusable
                // element on screen would steal VoiceOver focus from
                // "Game area" and disable `.allowsDirectInteraction`
                // for the swipes that followed. VoiceOver users reach
                // the same destinations via the Actions rotor on the
                // game area, which is always available and not subject
                // to gesture remapping.
                InGameMenuButton(
                    onOpenChat: { showingChat = true },
                    onOpenControls: { showingControls = true },
                    onOpenHelp: { showingHelp = true },
                    onOpenEventLog: { showingEventLog = true }
                )
                .padding(.top, 8)
                .padding(.trailing, 12)
                .accessibilityHidden(true)
            }
            .accessibilityHidden(viewModel.isEditMode)
            .allowsHitTesting(!viewModel.isEditMode)

            if viewModel.isEditMode {
                EditOverlay(viewModel: viewModel)
                    .background(Color(.systemBackground).ignoresSafeArea())
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingControls) {
            ControlsSheet(viewModel: viewModel, appState: appState)
        }
        .sheet(isPresented: $showingHelp) {
            HelpSheet(viewModel: viewModel, gestureSettings: gestureSettings)
        }
        .sheet(isPresented: $showingEventLog) {
            EventLogSheet(
                bufferSystem: viewModel.bufferSystem,
                speechManager: viewModel.speechManager
            )
        }
        // Escapable recovery when the *initial* connect never lands. The game
        // area is a single direct-touch element with no on-screen Back; this
        // native alert takes VoiceOver focus and gives an unmistakable way out,
        // answering the "stuck, can't go back, only force-quit" report.
        .alert("Couldn't connect", isPresented: $viewModel.initialConnectFailed) {
            Button("Retry") { viewModel.retryInitialConnect() }
            Button("Back to servers", role: .cancel) {
                viewModel.disconnect()
                appState.returnToLogin()
            }
        } message: {
            Text("Couldn't reach \(appState.credentials?.serverURL ?? "the server"). Check your connection and try again.")
        }
        .onAppear {
            viewModel.setup(appState: appState)
            // Pay the AVSpeechSynthesizer cold-start tax before the user
            // is waiting on real speech (see SpeechManager.prewarm docs).
            viewModel.speechManager.prewarm()
        }
        .onDisappear { viewModel.disconnect() }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                wasBackgrounded = true
            case .active:
                // Only force a reconnect on a real background→active cycle
                // (phone lock, app switcher). Ignore .inactive→.active blips
                // (Control Center, banner notifications) which don't kill the
                // socket.
                if wasBackgrounded {
                    wasBackgrounded = false
                    viewModel.forceReconnect()
                    // Re-warm the synth: a background→active cycle can let
                    // iOS unload the TTS voice rules and bring the cold-start
                    // bug back on the next utterance.
                    viewModel.speechManager.prewarm()
                }
            default:
                break
            }
        }
    }
}

// MARK: - In-game Menu Button

/// Small overlay button in the top-trailing corner of the game view.
/// Double-tap opens a confirmation dialog with Help, Controls, Recent
/// events, and Chat; guarantees a recovery path even if every gesture has
/// been remapped to none. The double-tap requirement matches the in-game
/// touch model so a stray finger landing on the menu icon doesn't pop a
/// sheet mid-play.
///
/// Note: the iOS-native confirmation dialog itself uses iOS-standard
/// single-tap activation (VO double-tap when VO is on). Customizing the
/// dialog's per-item activation isn't possible without replacing the
/// system control, and the dialog is a deliberate, transient surface that
/// the user already opted into — so keeping that part native is fine.
///
/// Low-vision parity: icon size and hit target scale with Dynamic Type.
/// Background is a near-opaque system surface (not 0.6 opacity over
/// arbitrary game scene content) so the button is visible regardless of
/// what's behind it; opacity bumps under Reduce Transparency / Increase
/// Contrast.
private struct InGameMenuButton: View {
    var onOpenChat: () -> Void
    var onOpenControls: () -> Void
    var onOpenHelp: () -> Void
    var onOpenEventLog: () -> Void

    @State private var showingMenu = false
    @Environment(\.lowVision) private var lv

    @ScaledMetric(relativeTo: .title2) private var iconPointSize: CGFloat = 28
    @ScaledMetric(relativeTo: .title2) private var hitSize: CGFloat = 48

    var body: some View {
        DoubleTapButton(action: { showingMenu = true }) {
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: iconPointSize, weight: lv.boldText ? .heavy : .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: max(hitSize, 44), height: max(hitSize, 44))
                .background(
                    Circle()
                        .fill(Color(.systemBackground).opacity(lv.overlaySurfaceOpacity))
                )
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(lv.overlayBorderOpacity),
                                lineWidth: lv.increasedContrast ? 2 : 1)
                )
                .accessibilityLabel("Menu")
                .accessibilityHint("Opens help, controls, chat, and the recent events log. Always available, no matter how gestures are configured.")
        }
        .fixedSize()
        .confirmationDialog("Menu", isPresented: $showingMenu, titleVisibility: .visible) {
            Button("Help") { onOpenHelp() }
            Button("Controls") { onOpenControls() }
            Button("Recent events") { onOpenEventLog() }
            Button("Chat") { onOpenChat() }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - UIViewRepresentable Bridge

private struct DirectTouchGameView: UIViewRepresentable {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var gestureSettings: GestureSettings
    var isSurfaceActive: Bool
    var onOpenChat: () -> Void
    var onOpenControls: () -> Void
    var onOpenHelp: () -> Void
    var onOpenEventLog: () -> Void

    func makeUIView(context: Context) -> GameTouchView {
        let view = GameTouchView()
        view.viewModel = viewModel
        view.gestureSettings = gestureSettings
        view.onOpenChat = onOpenChat
        view.onOpenControls = onOpenControls
        view.onOpenHelp = onOpenHelp
        view.onOpenEventLog = onOpenEventLog
        view.setSurfaceActive(isSurfaceActive)
        return view
    }

    func updateUIView(_ uiView: GameTouchView, context: Context) {
        uiView.viewModel = viewModel
        uiView.gestureSettings = gestureSettings
        uiView.onOpenChat = onOpenChat
        uiView.onOpenControls = onOpenControls
        uiView.onOpenHelp = onOpenHelp
        uiView.onOpenEventLog = onOpenEventLog
        uiView.setSurfaceActive(isSurfaceActive)
        uiView.onMenuUpdate()
    }
}

// MARK: - Game Touch View

/// Self-voicing touch view.
///
/// Gesture scheme (consistent finger grouping):
///
/// ONE FINGER — menu navigation:
///   Swipe left/right  — browse items (column movement in grid mode)
///   Swipe up/down      — row movement in grid mode
///   Hold and drag       — explore by touch in grid mode
///   Double-tap         — activate selected item
///   Single tap         — repeat current item
///   Long press         — enriched status (where you are + last event)
///
/// TWO FINGERS — game actions + speech control:
///   Scrub (zig-zag)    — go back / escape
///   Single tap         — stop speech (interrupt in-flight narration)
///   Double-tap         — primary action (roll, draw, etc.)
///   Swipe up           — check score
///   Swipe down         — add bot (lobby only)
///
/// THREE FINGERS — buffer system + recovery:
///   Swipe left/right   — previous/next buffer
///   Swipe up/down      — older/newer message
///   Tap                — open help menu
///   Double-tap         — repeat last server announcement
final class GameTouchView: UIView {
    var viewModel: MainViewModel?
    var gestureSettings: GestureSettings?
    var onOpenChat: (() -> Void)?
    var onOpenControls: (() -> Void)?
    var onOpenHelp: (() -> Void)?
    var onOpenEventLog: (() -> Void)?

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private var currentIndex = 0
    private var idleTimer: Timer?
    private let idleTimeout: TimeInterval = 8

    /// Whether the game area is the active input/speech surface (no sheet,
    /// edit overlay, or connect alert on top). The view survives beneath
    /// presented surfaces; while inactive, the idle re-announcer and grid
    /// explore stay quiet instead of interrupting the presented surface.
    private var isSurfaceActive = true

    // For two-finger scrub detection. History samples are the centroid of
    // the two touches, appended only after `scrubSampleMinDeltaX` of
    // horizontal travel — see `touchesMoved`.
    private var twoFingerTouchHistory: [CGPoint] = []
    private var twoFingerScrubRecognized = false
    /// Minimum horizontal travel between scrub history samples. Filters
    /// finger jitter so a counted direction reversal is real movement.
    private static let scrubSampleMinDeltaX: CGFloat = 8
    /// Direction reversals required to recognize a scrub. VoiceOver's own
    /// scrub gesture is a "z" — two reversals.
    private static let scrubReversalsRequired = 2

    // For grid explore-by-touch
    private var exploreTimer: Timer?
    private var isExploring = false
    private var lastExploreCell: Int = -1

    // MARK: - VoiceOver interaction mode
    //
    // The game area is one full-screen surface, and no single Apple flag makes
    // it both playable and escapable under VoiceOver:
    //   - `.allowsDirectInteraction` alone traps the user (VO can't navigate
    //     away — the "can't escape the game area" bug).
    //   - `.requiresActivation` fights the PRIMARY single-finger gesture: VO
    //     keeps the flicks until a deliberate double-tap, and every focus
    //     change silently drops passthrough with no cue — the "VoiceOver and
    //     the game conflict" reports.
    // So we own the mode ourselves:
    //   .voiceOverNavigation — traits = []; VO drives normally, the rotor
    //     actions work, Home-swipe escapes. A VO activation (double-tap) enters
    //     direct play. Default, and the safe/escapable state.
    //   .directPlay — traits = .allowsDirectInteraction + .silentOnTouch (NO
    //     .requiresActivation); raw gestures reach the game. A two-finger scrub
    //     (the universal VO escape) returns to navigation.
    //
    // Mutating traits on a live focused element is only honored by VoiceOver
    // after a `.layoutChanged` post (see `applyInteractionMode`). Whether that
    // is enough without a focus bounce is the one thing the on-device
    // experiment must confirm.
    private enum InteractionMode { case voiceOverNavigation, directPlay }
    private var interactionMode: InteractionMode = .voiceOverNavigation

    /// Throttle for `reassertInteractionMode` — one trait desync produces a
    /// burst of touch callbacks, and each re-assert posts a notification.
    private var lastTraitReassert: TimeInterval = 0
    private static let traitReassertMinInterval: TimeInterval = 1.0

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        isMultipleTouchEnabled = true
        setupGestures()
        setupAccessibility()
        registerTraitChangeHandlers()
        selectionFeedback.prepare()
        impactFeedback.prepare()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isMultipleTouchEnabled = true
        setupGestures()
        setupAccessibility()
        registerTraitChangeHandlers()
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = "Game area"
        // Traits, direct-touch options, value and hint are all mode-dependent —
        // `applyInteractionMode` is the single source of truth. We start in the
        // safe, fully-navigable VoiceOver-navigation mode.
        applyInteractionMode()
        // VoiceOver toggling mid-session invalidates the mode contract:
        // direct play entered under the previous state must not survive as
        // passthrough the user never activated this VoiceOver session, nor
        // as stale direct-touch traits when VoiceOver comes back later.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverStatusChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
    }

    @objc private func voiceOverStatusChanged() {
        guard interactionMode == .directPlay else { return }
        directTouchLog.notice("VoiceOver status changed in directPlay — resetting to navigation")
        exitDirectPlay(announce: false, refocus: false)
    }

    /// VoiceOver's cached view of our traits has drifted from
    /// `interactionMode` — raw touches or recognizer callbacks arrived while
    /// VoiceOver should own the screen. Re-apply and re-post rather than
    /// acting on input the user believes VoiceOver is handling.
    private func reassertInteractionMode() {
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastTraitReassert >= Self.traitReassertMinInterval else { return }
        lastTraitReassert = now
        directTouchLog.error("input arrived in \(String(describing: self.interactionMode), privacy: .public) with VoiceOver on — re-asserting traits")
        applyInteractionMode()
        UIAccessibility.post(notification: .layoutChanged, argument: self)
    }

    /// Apply the accessibility configuration for the current `interactionMode`.
    /// Called on setup and after every transition. When VoiceOver is already
    /// focused here, a trait change isn't re-read until a layout-change post —
    /// the transition helpers do that; initial setup doesn't need to.
    private func applyInteractionMode() {
        switch interactionMode {
        case .voiceOverNavigation:
            accessibilityTraits = []
            accessibilityDirectTouchOptions = []
            accessibilityValue = "VoiceOver navigation"
            accessibilityHint = "Double-tap to start playing with touch gestures. Or use the Actions rotor for Help, Controls, Chat, Recent events, and game actions."
        case .directPlay:
            accessibilityTraits = .allowsDirectInteraction
            // .silentOnTouch keeps VoiceOver quiet while a finger is down so it
            // doesn't talk over our self-voiced output. NO .requiresActivation:
            // we gate entry/exit ourselves so the primary single-finger gesture
            // is never captured by VoiceOver mid-play.
            accessibilityDirectTouchOptions = [.silentOnTouch]
            accessibilityValue = "Direct play"
            accessibilityHint = "Swipe to browse and double-tap to select. Two-finger scrub to return to VoiceOver navigation."
        }
    }

    /// Enter direct play: raw gestures start reaching the game. Triggered by a
    /// VoiceOver activation (double-tap) while in navigation mode.
    private func enterDirectPlay() {
        guard interactionMode != .directPlay else { return }
        interactionMode = .directPlay
        applyInteractionMode()
        // Force VoiceOver to re-read the now-direct-touch element. This is the
        // load-bearing, on-device-unverified step (see the mode comment above).
        UIAccessibility.post(notification: .layoutChanged, argument: self)
        viewModel?.speechManager.forceSelfVoicing = true
        directTouchLog.notice("enter directPlay; posted layoutChanged")
        speak("Direct play on. Two-finger scrub to return to VoiceOver.")
    }

    /// Return to VoiceOver navigation: VO drives normally again and the user can
    /// escape. Triggered by a two-finger scrub while in direct play.
    /// - Parameters:
    ///   - announce: speak the transition cue (skip for silent programmatic exits).
    ///   - refocus: post a layout change so a still-focused VoiceOver re-reads
    ///     the element. Skip when focus has already left (a sheet/edit overlay
    ///     took it), so we don't yank focus back.
    private func exitDirectPlay(announce: Bool, refocus: Bool) {
        guard interactionMode != .voiceOverNavigation else { return }
        // Speak the cue while forceSelfVoicing is still on so it takes the
        // synth path. speak() must stay synchronous: the old Task-hopped
        // version enqueued this after forceSelfVoicing was cleared below,
        // landing the cue on the VoiceOver announcement path where the
        // refocus readback preempted it — the "mode drops in silence" report.
        if announce { speak("VoiceOver navigation.") }
        interactionMode = .voiceOverNavigation
        applyInteractionMode()
        if refocus { UIAccessibility.post(notification: .layoutChanged, argument: self) }
        viewModel?.speechManager.forceSelfVoicing = false
        directTouchLog.notice("exit directPlay announce=\(announce, privacy: .public) refocus=\(refocus, privacy: .public)")
    }

    // MARK: - Trait Changes (low-vision)

    /// React to changes in the user's text size, contrast, or appearance
    /// while the game view is on screen. The view itself doesn't draw
    /// custom content (background is `.systemBackground`, gestures only),
    /// but the system background and any future visual additions should
    /// repaint when the user toggles dark mode or Increase Contrast mid
    /// session.
    private func registerTraitChangeHandlers() {
        let traits: [any UITrait] = [
            UITraitPreferredContentSizeCategory.self,
            UITraitAccessibilityContrast.self,
            UITraitUserInterfaceStyle.self,
        ]
        registerForTraitChanges(traits) { (self: GameTouchView, _: UITraitCollection) in
            // .systemBackground already adapts to dark/light + contrast,
            // but trigger a redraw so any descendant custom drawing
            // (added in the future) re-evaluates against the new traits.
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }

    // MARK: - Gesture Setup

    private func setupGestures() {
        // === ONE FINGER — menu navigation ===

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTap)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeRight))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 1
        addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeLeft))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 1
        addGestureRecognizer(swipeLeft)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeUp))
        swipeUp.direction = .up
        swipeUp.numberOfTouchesRequired = 1
        // Defer to the system's home-indicator gesture for swipes that
        // originate in the bottom edge zone — see the delegate method below.
        swipeUp.delegate = self
        addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeDown))
        swipeDown.direction = .down
        swipeDown.numberOfTouchesRequired = 1
        addGestureRecognizer(swipeDown)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        longPress.minimumPressDuration = 0.6
        longPress.numberOfTouchesRequired = 1
        addGestureRecognizer(longPress)

        // === TWO FINGERS — game actions ===
        // (Two-finger scrub is handled via touch events below)

        let twoDoubleTap = UITapGestureRecognizer(target: self, action: #selector(onTwoFingerDoubleTap))
        twoDoubleTap.numberOfTouchesRequired = 2
        twoDoubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(twoDoubleTap)

        // Two-finger single tap → stop speech. Must wait for the double-tap
        // recognizer to fail so a deliberate double-tap doesn't fire stop
        // speech first.
        let twoSingleTap = UITapGestureRecognizer(target: self, action: #selector(onTwoFingerSingleTap))
        twoSingleTap.numberOfTouchesRequired = 2
        twoSingleTap.numberOfTapsRequired = 1
        twoSingleTap.require(toFail: twoDoubleTap)
        addGestureRecognizer(twoSingleTap)

        let twoSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onTwoFingerSwipeUp))
        twoSwipeUp.direction = .up
        twoSwipeUp.numberOfTouchesRequired = 2
        addGestureRecognizer(twoSwipeUp)

        let twoSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onTwoFingerSwipeDown))
        twoSwipeDown.direction = .down
        twoSwipeDown.numberOfTouchesRequired = 2
        addGestureRecognizer(twoSwipeDown)

        // === THREE FINGERS — buffer system + recovery ===

        let threeSwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(onThreeFingerSwipeLeft))
        threeSwipeLeft.direction = .left
        threeSwipeLeft.numberOfTouchesRequired = 3
        addGestureRecognizer(threeSwipeLeft)

        let threeSwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(onThreeFingerSwipeRight))
        threeSwipeRight.direction = .right
        threeSwipeRight.numberOfTouchesRequired = 3
        addGestureRecognizer(threeSwipeRight)

        let threeSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onThreeFingerSwipeUp))
        threeSwipeUp.direction = .up
        threeSwipeUp.numberOfTouchesRequired = 3
        addGestureRecognizer(threeSwipeUp)

        let threeSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onThreeFingerSwipeDown))
        threeSwipeDown.direction = .down
        threeSwipeDown.numberOfTouchesRequired = 3
        addGestureRecognizer(threeSwipeDown)

        // Three-finger double tap → repeat last server announcement. The
        // single-tap recognizer (help menu) must wait for this to fail so a
        // deliberate double-tap doesn't fire help on the first tap.
        let threeDoubleTap = UITapGestureRecognizer(target: self, action: #selector(onThreeFingerDoubleTap))
        threeDoubleTap.numberOfTouchesRequired = 3
        threeDoubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(threeDoubleTap)

        let threeTap = UITapGestureRecognizer(target: self, action: #selector(onThreeFingerTap))
        threeTap.numberOfTouchesRequired = 3
        threeTap.numberOfTapsRequired = 1
        threeTap.require(toFail: threeDoubleTap)
        addGestureRecognizer(threeTap)
    }

    // MARK: - Touch Tracking (scrub + grid explore)

    /// Centroid of the currently-active touches when exactly two are down.
    /// Sampling the centroid instead of `touches.first` keeps the scrub
    /// history on one stable track: `Set<UITouch>.first` has no identity and
    /// alternates fingers between events, so the fingers' horizontal
    /// separation used to manufacture direction reversals that read as a
    /// scrub — randomly dropping the player out of direct play.
    private func twoFingerCentroid(in event: UIEvent?) -> CGPoint? {
        guard let active = event?.allTouches?.filter({
            $0.phase != .ended && $0.phase != .cancelled
        }), active.count == 2 else { return nil }
        let points = active.map { $0.location(in: self) }
        return CGPoint(x: (points[0].x + points[1].x) / 2,
                       y: (points[0].y + points[1].y) / 2)
    }

    /// Append a scrub sample only after real horizontal travel, so a counted
    /// sign flip is a deliberate change of direction rather than jitter.
    private func recordScrubSample(_ point: CGPoint) {
        if let last = twoFingerTouchHistory.last {
            guard abs(point.x - last.x) >= Self.scrubSampleMinDeltaX else { return }
        }
        twoFingerTouchHistory.append(point)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let allTouches = event?.allTouches else { return }

        // With VoiceOver on, raw touches belong to the app only in direct
        // play. Arrivals in navigation mode mean VoiceOver's trait cache has
        // drifted from ours — don't track a scrub or explore on touches the
        // user believes VoiceOver owns; re-assert the traits instead.
        if UIAccessibility.isVoiceOverRunning, interactionMode != .directPlay {
            reassertInteractionMode()
            return
        }

        if allTouches.count == 2 {
            // Two-finger scrub detection
            twoFingerTouchHistory.removeAll()
            twoFingerScrubRecognized = false
            if let point = twoFingerCentroid(in: event) {
                twoFingerTouchHistory.append(point)
            }
        } else if allTouches.count == 1,
                  let vm = viewModel, vm.gridEnabled, vm.gridWidth > 1 {
            // Grid explore: start after a short delay so swipes/taps fire first
            cancelExplore()
            exploreTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
                guard let self, let touch = allTouches.first else { return }
                self.isExploring = true
                self.lastExploreCell = -1
                self.exploreAtPosition(touch.location(in: self))
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let allTouches = event?.allTouches else { return }
        if UIAccessibility.isVoiceOverRunning, interactionMode != .directPlay { return }

        if allTouches.count == 2 && !twoFingerScrubRecognized {
            if let point = twoFingerCentroid(in: event) {
                recordScrubSample(point)
            }
            // Recognize a scrub once the hysteresis-filtered track reverses
            // horizontal direction `scrubReversalsRequired` times. Every
            // consecutive delta is ≥ scrubSampleMinDeltaX by construction,
            // so no per-delta magnitude check is needed here.
            if twoFingerTouchHistory.count >= 3 {
                var reversals = 0
                for i in 2..<twoFingerTouchHistory.count {
                    let prev = twoFingerTouchHistory[i-1].x - twoFingerTouchHistory[i-2].x
                    let curr = twoFingerTouchHistory[i].x - twoFingerTouchHistory[i-1].x
                    if prev * curr < 0 {
                        reversals += 1
                    }
                }
                if reversals >= Self.scrubReversalsRequired {
                    twoFingerScrubRecognized = true
                    onScrub()
                }
            }
        } else if allTouches.count == 1 && isExploring, let touch = touches.first {
            exploreAtPosition(touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        twoFingerTouchHistory.removeAll()
        twoFingerScrubRecognized = false
        cancelExplore()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        twoFingerTouchHistory.removeAll()
        twoFingerScrubRecognized = false
        cancelExplore()
    }

    // MARK: - Grid Explore by Touch

    private func cancelExplore() {
        exploreTimer?.invalidate()
        exploreTimer = nil
        isExploring = false
        lastExploreCell = -1
    }

    private func exploreAtPosition(_ point: CGPoint) {
        guard let vm = viewModel, vm.gridEnabled, vm.gridWidth > 1,
              !vm.menuItems.isEmpty else { return }

        let gridWidth = vm.gridWidth
        let gridHeight = (vm.menuItems.count + gridWidth - 1) / gridWidth

        let col = Int(point.x / bounds.width * CGFloat(gridWidth))
        let row = Int(point.y / bounds.height * CGFloat(gridHeight))

        let clampedCol = max(0, min(col, gridWidth - 1))
        let clampedRow = max(0, min(row, gridHeight - 1))

        let cellIndex = clampedRow * gridWidth + clampedCol
        guard cellIndex >= 0, cellIndex < vm.menuItems.count else { return }

        if cellIndex != lastExploreCell {
            lastExploreCell = cellIndex
            currentIndex = cellIndex
            vm.menuSelection = cellIndex
            selectionFeedback.selectionChanged()
            announceCurrentItem()
            resetIdleTimer()
        }
    }

    // MARK: - VoiceOver Support

    override func accessibilityActivate() -> Bool {
        // A VoiceOver activation (double-tap) enters direct play. It must NOT
        // also fire a game menu-select — overloading the one gesture selected a
        // random item on entry and made passthrough feel unreliable.
        directTouchLog.notice("accessibilityActivate -> enterDirectPlay")
        enterDirectPlay()
        return true
    }

    /// While VoiceOver focus is on this view, route our speech through
    /// AVSpeechSynthesizer instead of UIAccessibility.post(.announcement).
    /// The `.allowsDirectInteraction` trait makes VoiceOver re-announce
    /// "Game area" on every flick, and that focus chatter preempts our
    /// announcement posts — even at `.high` priority — leaving the user
    /// with no audible response to gestures. The synth path (with
    /// `prefersAssistiveTechnologySettings = true`) adopts VoiceOver's
    /// voice/rate/pitch so the user still hears their familiar voice,
    /// and the queue can't be drowned by VO focus events.
    override func accessibilityElementDidBecomeFocused() {
        super.accessibilityElementDidBecomeFocused()
        // Self-voice only while actually in direct play; in navigation mode
        // VoiceOver speaks the element itself.
        viewModel?.speechManager.forceSelfVoicing = (interactionMode == .directPlay)
        directTouchLog.debug("didBecomeFocused mode=\(String(describing: self.interactionMode), privacy: .public)")
    }

    override func accessibilityElementDidLoseFocus() {
        super.accessibilityElementDidLoseFocus()
        viewModel?.speechManager.forceSelfVoicing = false
        directTouchLog.debug("didLoseFocus mode=\(String(describing: self.interactionMode), privacy: .public)")
    }

    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            [
                // Game actions
                UIAccessibilityCustomAction(name: "Primary action") { [weak self] _ in
                    self?.perform(.primaryAction); return true
                },
                UIAccessibilityCustomAction(name: "Go back") { [weak self] _ in
                    self?.perform(.goBack); return true
                },
                UIAccessibilityCustomAction(name: "Check score") { [weak self] _ in
                    self?.perform(.checkScore); return true
                },
                UIAccessibilityCustomAction(name: "Add bot") { [weak self] _ in
                    self?.perform(.addBot); return true
                },
                UIAccessibilityCustomAction(name: "Status") { [weak self] _ in
                    self?.perform(.status); return true
                },
                // Self-voicing controls
                UIAccessibilityCustomAction(name: "Stop speech") { [weak self] _ in
                    self?.perform(.stopSpeech); return true
                },
                UIAccessibilityCustomAction(name: "Repeat last announcement") { [weak self] _ in
                    self?.perform(.repeatLastAnnouncement); return true
                },
                // Buffers
                UIAccessibilityCustomAction(name: "Previous buffer") { [weak self] _ in
                    self?.perform(.previousBuffer); return true
                },
                UIAccessibilityCustomAction(name: "Next buffer") { [weak self] _ in
                    self?.perform(.nextBuffer); return true
                },
                UIAccessibilityCustomAction(name: "Older message") { [weak self] _ in
                    self?.perform(.olderMessage); return true
                },
                UIAccessibilityCustomAction(name: "Newer message") { [weak self] _ in
                    self?.perform(.newerMessage); return true
                },
                // Screens
                UIAccessibilityCustomAction(name: "Open chat") { [weak self] _ in
                    self?.onOpenChat?(); return true
                },
                UIAccessibilityCustomAction(name: "Open controls") { [weak self] _ in
                    self?.onOpenControls?(); return true
                },
                UIAccessibilityCustomAction(name: "Help") { [weak self] _ in
                    self?.onOpenHelp?(); return true
                },
                UIAccessibilityCustomAction(name: "Recent events") { [weak self] _ in
                    self?.onOpenEventLog?(); return true
                },
            ]
        }
        set {}
    }

    // MARK: - Gesture Dispatch

    /// Central dispatch: looks up the action for a gesture type and executes it.
    private func dispatch(_ gestureType: GestureType) {
        // Key experiment signal: if this logs after activation, the flick
        // reached the game (passthrough engaged). If a post-activation flick
        // does VoiceOver navigation instead, this stays silent.
        directTouchLog.debug("dispatch gesture=\(String(describing: gestureType), privacy: .public) voOn=\(UIAccessibility.isVoiceOverRunning, privacy: .public) mode=\(String(describing: self.interactionMode), privacy: .public)")
        // Invariant: with VoiceOver running, the app acts on gestures only in
        // direct play. Anything arriving in navigation mode means VoiceOver's
        // cached traits have drifted from ours, or a recognizer armed by the
        // gesture that just exited direct play is still in flight — acting on
        // it is the app and VoiceOver fighting over one touch.
        guard !UIAccessibility.isVoiceOverRunning || interactionMode == .directPlay else {
            directTouchLog.error("dropped gesture=\(String(describing: gestureType), privacy: .public) in VoiceOver navigation mode")
            reassertInteractionMode()
            return
        }
        cancelExplore()
        let action = gestureSettings?.action(for: gestureType) ?? GestureSettings.defaultMapping[gestureType] ?? .none
        perform(action)
        resetIdleTimer()
    }

    /// Execute a gesture action.
    private func perform(_ action: GestureAction) {
        guard let vm = viewModel else { return }
        switch action {
        case .nextItem:
            guard !vm.menuItems.isEmpty else { return }
            let gridWidth = vm.gridWidth
            if vm.gridEnabled && gridWidth > 1 {
                // In grid mode, stay within the current row
                let col = currentIndex % gridWidth
                guard col < gridWidth - 1, currentIndex < vm.menuItems.count - 1 else { return }
            }
            if currentIndex < vm.menuItems.count - 1 {
                currentIndex += 1
                vm.menuSelection = currentIndex
                selectionFeedback.selectionChanged()
            }
            announceCurrentItem()
        case .previousItem:
            guard !vm.menuItems.isEmpty else { return }
            let gridWidth = vm.gridWidth
            if vm.gridEnabled && gridWidth > 1 {
                // In grid mode, stay within the current row
                let col = currentIndex % gridWidth
                guard col > 0 else { return }
            }
            if currentIndex > 0 {
                currentIndex -= 1
                vm.menuSelection = currentIndex
                selectionFeedback.selectionChanged()
            }
            announceCurrentItem()
        case .activateItem:
            guard !vm.menuItems.isEmpty,
                  currentIndex >= 0, currentIndex < vm.menuItems.count else {
                speak("Nothing to select")
                notificationFeedback.notificationOccurred(.error)
                return
            }
            impactFeedback.impactOccurred()
            vm.activateMenuItem(currentIndex)
        case .repeatItem:
            announceCurrentItem()
        case .goBack:
            impactFeedback.impactOccurred()
            vm.sendEscape()
            // The server almost always replies with a new menu and/or an
            // explicit speak packet for the resulting state; the local
            // "Back" announcement used to race that reply and one would
            // talk over the other. Leave audible feedback to the server;
            // the haptic confirms the gesture registered.
        case .primaryAction:
            impactFeedback.impactOccurred()
            // 1. Prefer server-declared primary action (newer servers)
            if let actionId = vm.primaryActionId,
               let index = vm.menuItems.firstIndex(where: { $0.id == actionId }) {
                vm.activateMenuItem(index)
                return
            }
            // 2. Fallback: scan for common primary-action IDs (works with any server)
            let commonPrimaryIDs = [
                "roll", "draw", "draw_card", "hit", "shoot", "play",
                "attack", "deal", "bid", "spin",
            ]
            for id in commonPrimaryIDs {
                if let index = vm.menuItems.firstIndex(where: { $0.id == id }) {
                    vm.activateMenuItem(index)
                    return
                }
            }
            // 3. Last resort: send space keybind
            vm.sendKeybind("space")
        case .checkScore:
            vm.sendKeybind("s")
        case .addBot:
            vm.sendKeybind("b")
        case .status:
            announceStatus()
        case .help:
            onOpenHelp?()
        case .previousBuffer:
            vm.previousBuffer()
        case .nextBuffer:
            vm.nextBuffer()
        case .olderMessage:
            vm.olderMessage()
        case .newerMessage:
            vm.newerMessage()
        case .gridUp:
            guard vm.gridEnabled, !vm.menuItems.isEmpty else { return }
            let newIndex = currentIndex - vm.gridWidth
            guard newIndex >= 0 else { return }
            currentIndex = newIndex
            vm.menuSelection = currentIndex
            selectionFeedback.selectionChanged()
            announceCurrentItem()
        case .gridDown:
            guard vm.gridEnabled, !vm.menuItems.isEmpty else { return }
            let newIndex = currentIndex + vm.gridWidth
            guard newIndex < vm.menuItems.count else { return }
            currentIndex = newIndex
            vm.menuSelection = currentIndex
            selectionFeedback.selectionChanged()
            announceCurrentItem()
        case .stopSpeech:
            // Soft haptic so the user knows the gesture registered even
            // though the next thing they hear is silence.
            selectionFeedback.selectionChanged()
            vm.stopSpeechNow()
        case .repeatLastAnnouncement:
            vm.repeatLastServerAnnouncement()
        case .none:
            break
        }
    }

    // MARK: - Gesture Handlers

    @objc private func onSwipeRight() { dispatch(.oneFingerSwipeRight) }
    @objc private func onSwipeLeft() { dispatch(.oneFingerSwipeLeft) }
    @objc private func onSwipeUp() { dispatch(.oneFingerSwipeUp) }
    @objc private func onSwipeDown() { dispatch(.oneFingerSwipeDown) }
    @objc private func onSingleTap() { dispatch(.oneFingerSingleTap) }

    @objc private func onDoubleTap() { dispatch(.oneFingerDoubleTap) }

    @objc private func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        dispatch(.oneFingerLongPress)
    }

    private func onScrub() {
        // Under VoiceOver in direct play, the two-finger scrub — the universal
        // VoiceOver "escape" gesture — returns to VoiceOver navigation instead
        // of sending a server "go back". Always available, nothing new to learn.
        if UIAccessibility.isVoiceOverRunning, interactionMode == .directPlay {
            directTouchLog.notice("scrub -> exit directPlay")
            exitDirectPlay(announce: true, refocus: true)
            return
        }
        dispatch(.twoFingerScrub)
    }
    @objc private func onTwoFingerSingleTap() { dispatch(.twoFingerSingleTap) }
    @objc private func onTwoFingerDoubleTap() { dispatch(.twoFingerDoubleTap) }
    @objc private func onTwoFingerSwipeUp() { dispatch(.twoFingerSwipeUp) }
    @objc private func onTwoFingerSwipeDown() { dispatch(.twoFingerSwipeDown) }

    @objc private func onThreeFingerSwipeLeft() { dispatch(.threeFingerSwipeLeft) }
    @objc private func onThreeFingerSwipeRight() { dispatch(.threeFingerSwipeRight) }
    @objc private func onThreeFingerSwipeUp() { dispatch(.threeFingerSwipeUp) }
    @objc private func onThreeFingerSwipeDown() { dispatch(.threeFingerSwipeDown) }
    @objc private func onThreeFingerTap() { dispatch(.threeFingerTap) }
    @objc private func onThreeFingerDoubleTap() { dispatch(.threeFingerDoubleTap) }

    // MARK: - Menu Updates

    func onMenuUpdate() {
        guard let vm = viewModel else { return }

        // Clamp index
        if vm.menuItems.isEmpty {
            currentIndex = 0
        } else if currentIndex >= vm.menuItems.count {
            currentIndex = vm.menuItems.count - 1
        }

        // Sync selection from viewModel
        if let sel = vm.menuSelection, sel >= 0, sel < vm.menuItems.count {
            currentIndex = sel
        }

        // Don't auto-announce on menu change — let server speech
        // (draw results, dice rolls, game announcements) come through
        // uninterrupted. The idle timer will announce if the user
        // doesn't interact within 8 seconds.
        //
        // We used to auto-activate single-item menus to fold "Roll" /
        // "Draw" prompts into the gesture that triggered them. That
        // misfired any time a regular turn menu shrank to a single
        // option — most notably the start of every Pig/Yahtzee turn,
        // which the server presents as just [Roll] until you've rolled
        // once. Result: the second turn auto-rolled without the player
        // doing anything. The right place to express "this action is
        // implicit" is the server's primary_action_id, not a count
        // heuristic on the client.
        resetIdleTimer()
    }

    // MARK: - Speech Helpers

    /// Speak with interrupt — for user-initiated navigation. Synchronous on
    /// purpose: UIView is @MainActor so the call is already isolated, and the
    /// old `Task { @MainActor }` hop deferred the enqueue past mode
    /// transitions — transition cues then read `forceSelfVoicing` after it
    /// had flipped and landed on the wrong speech path.
    private func speak(_ text: String) {
        viewModel?.speechManager.speak(text, interrupt: true)
    }

    /// Speak without interrupt — for queued announcements.
    private func speakQueued(_ text: String) {
        viewModel?.speechManager.speak(text, interrupt: false)
    }

    private func announceCurrentItem() {
        guard let vm = viewModel, !vm.menuItems.isEmpty else {
            speak("No items")
            return
        }
        // `currentIndex` is maintained by `onMenuUpdate` but the @Published
        // menu can shrink between updates. Re-clamp here so the idle-timer
        // path can never OOB.
        guard currentIndex >= 0, currentIndex < vm.menuItems.count else {
            speak("No items")
            return
        }
        let item = vm.menuItems[currentIndex]
        if vm.gridEnabled && vm.gridWidth > 1 {
            let row = currentIndex / vm.gridWidth + 1
            let col = currentIndex % vm.gridWidth + 1
            speak("\(item.text). Row \(row), column \(col)")
        } else {
            speak("\(item.text). \(currentIndex + 1) of \(vm.menuItems.count)")
        }
    }

    private func announceStatus() {
        guard let vm = viewModel else { return }
        // The view model now combines connection state, current menu surface,
        // and the most recent server announcement into a single oriented
        // sentence — see `enrichedStatusText` for the composition.
        speak(vm.enrichedStatusText())
    }

    // MARK: - Surface Activity + Idle Timer

    /// Called by the SwiftUI layer whenever a sheet, the edit overlay, or the
    /// connect alert appears over (or leaves) the game area.
    func setSurfaceActive(_ active: Bool) {
        guard active != isSurfaceActive else { return }
        isSurfaceActive = active
        if active {
            resetIdleTimer()
        } else {
            idleTimer?.invalidate()
            idleTimer = nil
            cancelExplore()
        }
    }

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = nil
        // While a presented surface has the user's attention, the game item
        // chatter would interrupt it — the view survives beneath sheets and
        // onMenuUpdate keeps firing on server pushes.
        guard isSurfaceActive else { return }
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeout, repeats: false) { [weak self] _ in
            self?.onIdle()
        }
    }

    private func onIdle() {
        guard let vm = viewModel, !vm.menuItems.isEmpty, isSurfaceActive else { return }
        // In VoiceOver navigation mode the element speaks on demand;
        // unsolicited item re-announcements just interrupt whatever VoiceOver
        // is reading. The idle re-announce is a self-voicing / direct-play
        // feature.
        if UIAccessibility.isVoiceOverRunning && interactionMode != .directPlay { return }
        // Don't cut into in-flight narration (round summaries, win
        // announcements, multi-line rule reads can easily run past the 8s
        // idle window). Re-arm the timer and try again once speech drains.
        if vm.speechManager.isSpeaking {
            resetIdleTimer()
            return
        }
        announceCurrentItem()
    }

    deinit {
        idleTimer?.invalidate()
        exploreTimer?.invalidate()
    }
}

// MARK: - GameTouchView gesture delegate

extension GameTouchView: UIGestureRecognizerDelegate {

    /// Hand the bottom-edge zone back to the system so the iPhone 15 Pro
    /// (and any device with a home indicator) can still swipe up to home.
    /// Without this, our one-finger swipe-up recognizer eats the gesture
    /// before the system can claim it, trapping the user inside the app.
    /// Other gestures (taps, swipe-down, multi-finger) are unaffected.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        guard let swipe = gestureRecognizer as? UISwipeGestureRecognizer,
              swipe.direction == .up,
              swipe.numberOfTouchesRequired == 1
        else {
            return true
        }
        let location = touch.location(in: self)
        let homeIndicatorZone: CGFloat = 40
        return location.y < bounds.height - homeIndicatorZone
    }
}

// MARK: - Edit Overlay

private struct EditOverlay: View {
    @ObservedObject var viewModel: MainViewModel
    @FocusState private var editFocused: Bool
    @AccessibilityFocusState private var editA11yFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(viewModel.editPrompt)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            if viewModel.editMultiline {
                TextEditor(text: $viewModel.editText)
                    .font(.body)
                    .frame(minHeight: 120)
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator)))
                    .padding(.horizontal, 16)
                    .disabled(viewModel.editReadOnly)
                    .focused($editFocused)
                    .accessibilityLabel(viewModel.editPrompt)
                    .accessibilityFocused($editA11yFocused)
            } else {
                TextField(viewModel.editPrompt, text: $viewModel.editText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                    .disabled(viewModel.editReadOnly)
                    .focused($editFocused)
                    .accessibilityLabel(viewModel.editPrompt)
                    .accessibilityFocused($editA11yFocused)
                    .onSubmit { viewModel.submitEdit() }
            }
            HStack(spacing: 16) {
                DoubleTapButton(action: { viewModel.cancelEdit() }) {
                    Text("Cancel")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                }
                .fixedSize()
                if !viewModel.editReadOnly {
                    DoubleTapButton(action: { viewModel.submitEdit() }) {
                        Text("Submit")
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .fixedSize()
                }
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .onAppear {
            editFocused = true
            // VoiceOver focus has to be moved off the (now hidden)
            // allowsDirectInteraction game view explicitly, or VO stays in
            // direct-touch pass-through with no way to reach the field.
            // FocusState set during onAppear is unreliable while VO is
            // processing the hierarchy change, so re-assert both once it
            // has settled.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                editFocused = true
                editA11yFocused = true
            }
        }
    }
}

// MARK: - Chat Sheet

private struct ChatSheet: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var chatFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(viewModel.historyItems.suffix(30)) { item in
                    Text(item.text).font(.body)
                }
                .listStyle(.plain)
                Divider()
                HStack(spacing: 8) {
                    TextField("Type a message", text: $viewModel.chatText)
                        .textFieldStyle(.roundedBorder)
                        .focused($chatFocused)
                        .onSubmit { viewModel.sendChat() }
                        .submitLabel(.send)
                        .accessibilityLabel("Chat message")
                        .accessibilityHint("Slash for commands, dot for global chat. Return key sends.")
                    DoubleTapButton(
                        isEnabled: !viewModel.chatText.trimmingCharacters(in: .whitespaces).isEmpty,
                        action: { viewModel.sendChat() },
                    ) {
                        Image(systemName: "paperplane.fill")
                            .accessibilityLabel("Send")
                    }
                    .fixedSize()
                }
                .padding(12)
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            chatFocused = true
            viewModel.speechManager.speakTransition("Chat opened.")
        }
        .onDisappear { viewModel.speechManager.speakTransition("Chat closed.") }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Controls Sheet

private struct ControlsSheet: View {
    @ObservedObject var viewModel: MainViewModel
    var appState: AppState
    @Environment(\.dismiss) private var dismiss
    // Observe the ignore list so the "Manage list (N)" row count refreshes
    // immediately after the user adds or removes someone in the child view.
    @ObservedObject private var ignoreList: IgnoreList

    init(viewModel: MainViewModel, appState: AppState) {
        self.viewModel = viewModel
        self.appState = appState
        self._ignoreList = ObservedObject(wrappedValue: viewModel.ignoreList)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Buffers") {
                    if let info = viewModel.currentBufferInfo {
                        Text(info).lowVisionSecondary()
                    }
                    DoubleTapButton("Previous buffer") { viewModel.previousBuffer() }
                    DoubleTapButton("Next buffer") { viewModel.nextBuffer() }
                    DoubleTapButton("Older message") { viewModel.olderMessage() }
                    DoubleTapButton("Newer message") { viewModel.newerMessage() }
                    DoubleTapButton("Toggle mute") { viewModel.toggleBufferMute() }
                }
                Section("Volume") {
                    volumeRow("Music", viewModel.soundManager.musicVolume,
                              down: { viewModel.adjustMusicVolume(delta: -0.1) },
                              up: { viewModel.adjustMusicVolume(delta: 0.1) })
                    volumeRow("Ambience", viewModel.soundManager.ambienceVolume,
                              down: { viewModel.adjustAmbienceVolume(delta: -0.1) },
                              up: { viewModel.adjustAmbienceVolume(delta: 0.1) })
                }
                Section("Ignored users") {
                    DoubleTapButton("Ignore last chatter") {
                        viewModel.ignoreLastChatter()
                    }
                    NavigationLink("Manage list (\(ignoreList.usernames.count))") {
                        IgnoreListView(viewModel: viewModel)
                    }
                    .accessibilityHint("Add or remove ignored users")
                }
                if viewModel.voiceAvailable {
                    Section("Voice") {
                        DoubleTapButton("Join voice") { viewModel.joinVoice() }
                        DoubleTapButton("Toggle microphone") { viewModel.toggleVoiceMicrophone() }
                        DoubleTapButton("Leave voice", role: .destructive) { viewModel.leaveVoice() }
                    }
                }
                Section("Table") {
                    DoubleTapButton("Leave Table", role: .destructive) {
                        viewModel.requestLeaveTable()
                        dismiss()
                    }
                }
                Section("Connection") {
                    DoubleTapButton("Ping server") { viewModel.sendPing() }
                    DoubleTapButton("Online users") { viewModel.requestOnlineUsers() }
                    DoubleTapButton("Disconnect", role: .destructive) {
                        viewModel.disconnect()
                        appState.returnToLogin()
                        dismiss()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear { viewModel.speechManager.speakTransition("Controls opened.") }
        .onDisappear { viewModel.speechManager.speakTransition("Controls closed.") }
        .presentationDetents([.medium, .large])
    }

    private func volumeRow(_ label: String, _ value: Float, down: @escaping () -> Void, up: @escaping () -> Void) -> some View {
        VolumeRow(label: label, value: value, down: down, up: up)
    }
}

/// Stepper-style volume control. Uses visible text glyphs ("−" / "+") so
/// the controls scale with Dynamic Type and stay legible for low-vision
/// users — an icon-only minus.circle is fine for VoiceOver but barely
/// visible if you have partial sight and a screen reader off. Adjustable
/// via VoiceOver swipe too.
private struct VolumeRow: View {
    let label: String
    let value: Float
    let down: () -> Void
    let up: () -> Void

    @Environment(\.lowVision) private var lv

    private var pct: Int { Int((value * 100).rounded()) }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.body)
                    .fontWeight(lv.boldText ? .semibold : .regular)
                Text("\(pct)%")
                    .font(.callout)
                    .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            Spacer()
            DoubleTapButton(action: down) {
                Text("−")
                    .font(.title3)
                    .fontWeight(lv.boldText ? .bold : .semibold)
                    .frame(minWidth: 36, minHeight: 36)
                    .background(Color(.tertiarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .accessibilityLabel("Decrease \(label) volume")
            }
            .fixedSize()
            DoubleTapButton(action: up) {
                Text("+")
                    .font(.title3)
                    .fontWeight(lv.boldText ? .bold : .semibold)
                    .frame(minWidth: 36, minHeight: 36)
                    .background(Color(.tertiarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .accessibilityLabel("Increase \(label) volume")
            }
            .fixedSize()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) volume: \(pct) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: up()
            case .decrement: down()
            @unknown default: break
            }
        }
    }
}

// MARK: - Ignore List Management

private struct IgnoreListView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject private var ignoreList: IgnoreList
    @State private var newName: String = ""
    @FocusState private var nameFocused: Bool

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        self._ignoreList = ObservedObject(wrappedValue: viewModel.ignoreList)
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 8) {
                    TextField("Username to ignore", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .focused($nameFocused)
                        .submitLabel(.done)
                        .onSubmit(addCurrent)
                        .accessibilityHint("Type a player's name and tap Add to ignore them.")
                    DoubleTapButton(
                        isEnabled: !newName.trimmingCharacters(in: .whitespaces).isEmpty,
                        action: addCurrent,
                    ) {
                        Text("Add")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .fixedSize()
                }
            } footer: {
                Text("Ignored players' chat, table announcements, and table listings are hidden from you. The list syncs across your devices when the server supports it.")
                    .font(.footnote)
            }

            Section("Currently ignored") {
                if ignoreList.usernames.isEmpty {
                    Text("No ignored users.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(ignoreList.usernames, id: \.self) { name in
                        HStack {
                            Text(name)
                            Spacer()
                            DoubleTapButton(action: { viewModel.unignoreUser(name) }) {
                                Text("Unignore")
                                    .font(.callout)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(.secondarySystemBackground), in: Capsule())
                            }
                            .fixedSize()
                            .accessibilityLabel("Unignore \(name)")
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(name), ignored")
                        .accessibilityAction(named: "Unignore") {
                            viewModel.unignoreUser(name)
                        }
                    }
                }
            }
        }
        .navigationTitle("Ignored")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.speechManager.speakTransition("Ignored users.") }
    }

    private func addCurrent() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        viewModel.ignoreUser(trimmed)
        newName = ""
        nameFocused = true
    }
}

// MARK: - Help Sheet

private struct HelpSheet: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var gestureSettings: GestureSettings
    @Environment(\.dismiss) private var dismiss

    /// Game rules from the server, split into one item per line so VoiceOver
    /// can flick through them rule-by-rule instead of reading the whole block.
    private var gameRules: [String] {
        guard let text = viewModel.helpText, !text.isEmpty else { return [] }
        return text
            .split(whereSeparator: { $0.isNewline })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    /// Context-sensitive tips based on what's currently in the menu.
    private var contextTips: [String] {
        var tips: [String] = []
        let itemTexts = viewModel.menuItems.map { $0.text.lowercased() }

        if itemTexts.contains(where: { $0.contains("start") }) {
            tips.append("Double-tap to start the game.")
            tips.append("Two-finger swipe down to add a bot.")
        }
        if itemTexts.contains(where: { $0.contains("of ") }) {
            tips.append("Swipe to browse cards, double-tap to play.")
            tips.append("Two-finger double-tap to draw.")
        }
        if itemTexts.contains(where: { $0.contains("roll") || $0.contains("dice") }) {
            tips.append("Two-finger double-tap to roll.")
        }
        if viewModel.gridEnabled && viewModel.gridWidth > 1 {
            let rows = max(1, viewModel.menuItems.count / viewModel.gridWidth)
            tips.append("Grid mode: \(viewModel.gridWidth) columns, \(rows) rows.")
            tips.append("Swipe up or down to move between rows.")
            tips.append("Hold and drag to explore the grid by touch.")
        }
        return tips
    }

    var body: some View {
        NavigationStack {
            List {
                if !gameRules.isEmpty {
                    Section("Game Rules") {
                        ForEach(gameRules, id: \.self) { rule in
                            Text(rule).font(.body)
                        }
                    }
                }
                if !contextTips.isEmpty {
                    Section("Tips for This Screen") {
                        ForEach(contextTips, id: \.self) { tip in
                            Text(tip).font(.body)
                        }
                    }
                }
                ForEach([1, 2, 3], id: \.self) { fingerCount in
                    let label = fingerCount == 1 ? "One Finger" : fingerCount == 2 ? "Two Fingers" : "Three Fingers"
                    Section(label) {
                        ForEach(GestureType.allCases.filter { $0.fingerCount == fingerCount }) { gesture in
                            let action = gestureSettings.action(for: gesture)
                            if action != .none {
                                helpRow(gesture.displayName, action.displayName)
                            }
                        }
                    }
                }
                Section("On-screen Buttons") {
                    helpRow("Chat", "Send messages to players")
                    helpRow("Back", "Go back")
                    helpRow("Gestures", "Customize gesture mappings")
                    helpRow("Controls", "Volume, buffers, connection")
                    helpRow("Help", "This screen")
                }
                Section("VoiceOver Actions Rotor") {
                    helpRow("How to find it", "In VoiceOver navigation mode, flick up or down with one finger on the game area until you hear \"Actions\". Then flick up or down to pick one and double-tap to run it.")
                    helpRow("If you are in direct play", "One-finger flicks go to the game while direct play is on, so the rotor isn't reachable there. Two-finger scrub first — that returns to VoiceOver navigation — then use the rotor.")
                    helpRow("Always available", "The rotor lists Help, Controls, Chat, Recent events, Status, and the game actions. It works no matter how gestures are configured — after a two-finger scrub, it is always there.")
                    helpRow("Why not the corner button?", "The Menu button in the top-right is hidden from VoiceOver on purpose — a second focusable element would steal focus from the game area and break direct-touch gestures. The rotor replaces it for VoiceOver users.")
                }
                Section("Tips") {
                    Text("The app speaks everything itself. VoiceOver is optional but supported.")
                        .font(.callout).lowVisionSecondary()
                    Text("After 8 seconds idle, the current item repeats.")
                        .font(.callout).lowVisionSecondary()
                    Text("Customize gestures with the Gestures button in the toolbar.")
                        .font(.callout).lowVisionSecondary()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear { viewModel.speechManager.speakTransition("Help opened.") }
        .onDisappear { viewModel.speechManager.speakTransition("Help closed.") }
    }

    private func helpRow(_ gesture: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(gesture).fontWeight(.medium)
            Text(description).font(.callout).lowVisionSecondary()
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Event Log Sheet

/// Visual viewer for the existing per-buffer message history. The iOS app
/// already separates server narration into named buffers (table, chats,
/// activity, misc, plus a unioned "all"), and the buffer-navigation
/// gestures + ControlsSheet buttons let blind users scrub through them by
/// speech. What was missing — and what this sheet fills — is a visible
/// scrollback for low-vision players: a buffer picker at the top, the
/// chosen buffer's messages below with timestamps, sized for Dynamic Type.
///
/// Reads directly from ``MainViewModel/bufferSystem`` rather than keeping
/// a parallel log: the buffer system is already the source of truth for
/// "things the server told us", respects user mute choices, and survives
/// reconnect / scene-phase transitions. Mirrors the desktop client's
/// `history_text` widget pattern.
private struct EventLogSheet: View {
    @ObservedObject var bufferSystem: BufferSystem
    let speechManager: SpeechManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.lowVision) private var lv

    @State private var selectedBufferName: String = "all"

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .none
        return f
    }()

    private var selectedBuffer: BufferSystem.Buffer? {
        bufferSystem.buffers.first(where: { $0.name == selectedBufferName })
    }

    private var items: [BufferItem] {
        selectedBuffer?.items ?? []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                bufferPicker
                Divider()
                Group {
                    if items.isEmpty {
                        emptyState
                    } else {
                        list
                    }
                }
            }
            .navigationTitle("Recent Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: repeatLastInBuffer) {
                        Label("Repeat last", systemImage: "speaker.wave.2.fill")
                    }
                    .accessibilityLabel("Repeat last message in this buffer")
                    .disabled(items.isEmpty)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var bufferPicker: some View {
        // Menu-style picker because the segmented control's tighter
        // hit targets get awkward at accessibility-tier Dynamic Type
        // sizes; Menu scales cleanly and reads as a single accessible
        // element to VoiceOver.
        Menu {
            ForEach(bufferSystem.buffers, id: \.name) { buffer in
                Button {
                    selectedBufferName = buffer.name
                } label: {
                    let mutedTag = buffer.isMuted ? " (muted)" : ""
                    Text("\(buffer.name.capitalized) — \(buffer.items.count)\(mutedTag)")
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "tray.full.fill")
                    .symbolRenderingMode(.hierarchical)
                Text("Buffer: \(selectedBufferName.capitalized)")
                    .font(.body)
                    .fontWeight(lv.boldText ? .semibold : .regular)
                if let buffer = selectedBuffer, buffer.isMuted {
                    Text("(muted)")
                        .font(.caption)
                        .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("Choose buffer. Currently showing \(selectedBufferName).")
        .accessibilityHint("Switches the visible message history to another buffer.")
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.largeTitle)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
                .accessibilityHidden(true)
            Text("No messages in \(selectedBufferName).")
                .font(.body)
                .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var list: some View {
        // Newest at the top so the most recent message is the first
        // thing the eye / VoiceOver focus lands on. Reverse is fine —
        // buffers cap at 500 items, well within in-memory reverse cost.
        let reversed = Array(items.reversed())
        return List {
            ForEach(reversed) { item in
                row(for: item)
            }
        }
        .listStyle(.plain)
    }

    private func row(for item: BufferItem) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.text)
                .font(.body)
                .fontWeight(lv.boldText ? .semibold : .regular)
                .fixedSize(horizontal: false, vertical: true)
            Text(Self.formatter.string(from: item.timestamp))
                .font(.caption)
                .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    /// Re-speak the most recent message in the currently-viewed buffer.
    /// Lets a low-vision player look at the log, find the line they
    /// want to hear again, and tap the toolbar button — without needing
    /// to remember which gesture maps to "repeat last".
    private func repeatLastInBuffer() {
        guard let last = items.last else { return }
        speechManager.speakAnnouncement(last.text)
    }
}

#endif
