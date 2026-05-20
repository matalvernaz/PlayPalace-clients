#if os(iOS)
import AVFoundation
import SwiftUI
import UIKit

// MARK: - Main View

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

    var body: some View {
        Group {
            if viewModel.isEditMode {
                EditOverlay(viewModel: viewModel)
            } else {
                ZStack(alignment: .topTrailing) {
                    DirectTouchGameView(
                        viewModel: viewModel,
                        gestureSettings: gestureSettings,
                        onOpenChat: { showingChat = true },
                        onOpenControls: { showingControls = true },
                        onOpenHelp: { showingHelp = true }
                    )
                    // Leave the bottom safe area free of the direct-touch
                    // view so the iPhone home-indicator gesture isn't
                    // swallowed by `allowsDirectInteraction`. iOS routes
                    // the system swipe-up via that strip; if our view
                    // owns it, the user can't leave the app.
                    .ignoresSafeArea(.container, edges: [.top, .horizontal])

                    // Always-visible recovery affordance. Reachable regardless
                    // of the user's gesture mappings — even if Help and Go
                    // Back have been remapped to None, this button stays
                    // available so a player can never lock themselves out
                    // of help, controls, or leaving the table.
                    InGameMenuButton(
                        onOpenChat: { showingChat = true },
                        onOpenControls: { showingControls = true },
                        onOpenHelp: { showingHelp = true }
                    )
                    .padding(.top, 8)
                    .padding(.trailing, 12)
                }
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
        .onAppear { viewModel.setup(appState: appState) }
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
                }
            default:
                break
            }
        }
    }
}

// MARK: - In-game Menu Button

/// Small overlay button in the top-trailing corner of the game view.
/// Double-tap opens a confirmation dialog with Help, Controls, and Chat;
/// guarantees a recovery path even if every gesture has been remapped to
/// none. The double-tap requirement matches the in-game touch model so a
/// stray finger landing on the menu icon doesn't pop a sheet mid-play.
///
/// Note: the iOS-native confirmation dialog itself uses iOS-standard
/// single-tap activation (VO double-tap when VO is on). Customizing the
/// dialog's per-item activation isn't possible without replacing the
/// system control, and the dialog is a deliberate, transient surface that
/// the user already opted into — so keeping that part native is fine.
private struct InGameMenuButton: View {
    var onOpenChat: () -> Void
    var onOpenControls: () -> Void
    var onOpenHelp: () -> Void

    @State private var showingMenu = false

    var body: some View {
        DoubleTapButton(action: { showingMenu = true }) {
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 28, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(Color(.systemBackground).opacity(0.6), in: Circle())
                .accessibilityLabel("Menu")
                .accessibilityHint("Opens help, controls, and chat. Always available, no matter how gestures are configured.")
        }
        .fixedSize()
        .confirmationDialog("Menu", isPresented: $showingMenu, titleVisibility: .visible) {
            Button("Help") { onOpenHelp() }
            Button("Controls") { onOpenControls() }
            Button("Chat") { onOpenChat() }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - UIViewRepresentable Bridge

private struct DirectTouchGameView: UIViewRepresentable {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var gestureSettings: GestureSettings
    var onOpenChat: () -> Void
    var onOpenControls: () -> Void
    var onOpenHelp: () -> Void

    func makeUIView(context: Context) -> GameTouchView {
        let view = GameTouchView()
        view.viewModel = viewModel
        view.gestureSettings = gestureSettings
        view.onOpenChat = onOpenChat
        view.onOpenControls = onOpenControls
        view.onOpenHelp = onOpenHelp
        return view
    }

    func updateUIView(_ uiView: GameTouchView, context: Context) {
        uiView.viewModel = viewModel
        uiView.gestureSettings = gestureSettings
        uiView.onOpenChat = onOpenChat
        uiView.onOpenControls = onOpenControls
        uiView.onOpenHelp = onOpenHelp
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

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private var currentIndex = 0
    private var idleTimer: Timer?
    private let idleTimeout: TimeInterval = 8

    // For two-finger scrub detection
    private var twoFingerTouchHistory: [CGPoint] = []
    private var twoFingerScrubRecognized = false

    // For grid explore-by-touch
    private var exploreTimer: Timer?
    private var isExploring = false
    private var lastExploreCell: Int = -1

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        isMultipleTouchEnabled = true
        setupGestures()
        setupAccessibility()
        selectionFeedback.prepare()
        impactFeedback.prepare()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isMultipleTouchEnabled = true
        setupGestures()
        setupAccessibility()
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .allowsDirectInteraction
        accessibilityLabel = "Game area"
        accessibilityHint = "Swipe left and right to browse. Double-tap to select. Use the VoiceOver Actions rotor for Help, Controls, Chat, and game actions. The Menu button in the top right is always available too."
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let allTouches = event?.allTouches else { return }

        if allTouches.count == 2 {
            // Two-finger scrub detection
            twoFingerTouchHistory.removeAll()
            twoFingerScrubRecognized = false
            if let touch = touches.first {
                twoFingerTouchHistory.append(touch.location(in: self))
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

        if allTouches.count == 2 && !twoFingerScrubRecognized {
            if let touch = touches.first {
                twoFingerTouchHistory.append(touch.location(in: self))
            }
            // Detect scrub: 3+ direction changes in horizontal movement
            if twoFingerTouchHistory.count >= 4 {
                var directionChanges = 0
                for i in 2..<twoFingerTouchHistory.count {
                    let prev = twoFingerTouchHistory[i-1].x - twoFingerTouchHistory[i-2].x
                    let curr = twoFingerTouchHistory[i].x - twoFingerTouchHistory[i-1].x
                    if prev * curr < 0 && abs(curr) > 5 {
                        directionChanges += 1
                    }
                }
                if directionChanges >= 2 {
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
        onDoubleTap()
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
        viewModel?.speechManager.forceSelfVoicing = true
    }

    override func accessibilityElementDidLoseFocus() {
        super.accessibilityElementDidLoseFocus()
        viewModel?.speechManager.forceSelfVoicing = false
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
            ]
        }
        set {}
    }

    // MARK: - Gesture Dispatch

    /// Central dispatch: looks up the action for a gesture type and executes it.
    private func dispatch(_ gestureType: GestureType) {
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

    private func onScrub() { dispatch(.twoFingerScrub) }
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

    /// Speak with interrupt — for user-initiated navigation.
    private func speak(_ text: String) {
        Task { @MainActor in
            viewModel?.speechManager.speak(text, interrupt: true)
        }
    }

    /// Speak without interrupt — for queued announcements.
    private func speakQueued(_ text: String) {
        Task { @MainActor in
            viewModel?.speechManager.speak(text, interrupt: false)
        }
    }

    private func announceCurrentItem() {
        guard let vm = viewModel, !vm.menuItems.isEmpty else {
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

    // MARK: - Idle Timer

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleTimeout, repeats: false) { [weak self] _ in
            self?.onIdle()
        }
    }

    private func onIdle() {
        guard let vm = viewModel, !vm.menuItems.isEmpty else { return }
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
            } else {
                TextField(viewModel.editPrompt, text: $viewModel.editText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                    .disabled(viewModel.editReadOnly)
                    .focused($editFocused)
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
        .onAppear { editFocused = true }
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
                        Text(info).foregroundStyle(.secondary)
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
        HStack {
            Text("\(label): \(Int(value * 100))%")
            Spacer()
            DoubleTapButton(action: down) {
                Image(systemName: "minus.circle")
                    .accessibilityLabel("\(label) down")
            }
            .fixedSize()
            DoubleTapButton(action: up) {
                Image(systemName: "plus.circle")
                    .accessibilityLabel("\(label) up")
            }
            .fixedSize()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) volume: \(Int(value * 100)) percent")
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
                Section("Tips") {
                    Text("The app speaks everything itself. VoiceOver is optional but supported.")
                        .font(.callout).foregroundStyle(.secondary)
                    Text("After 8 seconds idle, the current item repeats.")
                        .font(.callout).foregroundStyle(.secondary)
                    Text("Customize gestures with the Gestures button in the toolbar.")
                        .font(.callout).foregroundStyle(.secondary)
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
            Text(description).font(.callout).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#endif
