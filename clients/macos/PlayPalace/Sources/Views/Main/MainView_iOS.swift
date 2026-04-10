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
    @State private var showingChat = false
    @State private var showingControls = false
    @State private var showingHelp = false
    @State private var showingGestureSettings = false

    var body: some View {
        Group {
            if viewModel.isEditMode {
                EditOverlay(viewModel: viewModel)
            } else {
                DirectTouchGameView(
                    viewModel: viewModel,
                    gestureSettings: gestureSettings,
                    onOpenChat: { showingChat = true },
                    onOpenControls: { showingControls = true },
                    onOpenHelp: { showingHelp = true }
                )
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingControls) {
            ControlsSheet(viewModel: viewModel, appState: appState)
        }
        .sheet(isPresented: $showingHelp) {
            HelpSheet(gestureSettings: gestureSettings)
        }
        .onAppear { viewModel.setup(appState: appState) }
        .onDisappear { viewModel.disconnect() }
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
///   Swipe left/right  — browse items
///   Double-tap         — activate selected item
///   Single tap         — repeat current item
///   Long press         — detailed status
///
/// TWO FINGERS — game actions:
///   Scrub (zig-zag)    — go back / escape
///   Double-tap         — primary action (roll, draw, etc.)
///   Swipe up           — check score
///   Swipe down         — add bot (lobby only)
///
/// THREE FINGERS — buffer system:
///   Swipe left/right   — previous/next buffer
///   Swipe up/down      — older/newer message
///   Tap                — announce help
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
    private var lastMenuItemCount = -1
    private var idleTimer: Timer?
    private let idleTimeout: TimeInterval = 8

    // For two-finger scrub detection
    private var twoFingerTouchHistory: [CGPoint] = []
    private var twoFingerScrubRecognized = false

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
        accessibilityHint = "Swipe left and right to browse. Double-tap to select."
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

        let twoSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(onTwoFingerSwipeUp))
        twoSwipeUp.direction = .up
        twoSwipeUp.numberOfTouchesRequired = 2
        addGestureRecognizer(twoSwipeUp)

        let twoSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onTwoFingerSwipeDown))
        twoSwipeDown.direction = .down
        twoSwipeDown.numberOfTouchesRequired = 2
        addGestureRecognizer(twoSwipeDown)

        // === THREE FINGERS — buffer system ===

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

        let threeTap = UITapGestureRecognizer(target: self, action: #selector(onThreeFingerTap))
        threeTap.numberOfTouchesRequired = 3
        addGestureRecognizer(threeTap)
    }

    // MARK: - Two-Finger Scrub Detection (zig-zag)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let allTouches = event?.allTouches, allTouches.count == 2 {
            twoFingerTouchHistory.removeAll()
            twoFingerScrubRecognized = false
            if let touch = touches.first {
                twoFingerTouchHistory.append(touch.location(in: self))
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let allTouches = event?.allTouches, allTouches.count == 2,
              !twoFingerScrubRecognized else { return }
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
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        twoFingerTouchHistory.removeAll()
        twoFingerScrubRecognized = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        twoFingerTouchHistory.removeAll()
        twoFingerScrubRecognized = false
    }

    // MARK: - VoiceOver Support

    override func accessibilityActivate() -> Bool {
        onDoubleTap()
        return true
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
            if currentIndex < vm.menuItems.count - 1 {
                currentIndex += 1
                vm.menuSelection = currentIndex
                selectionFeedback.selectionChanged()
            }
            announceCurrentItem()
        case .previousItem:
            guard !vm.menuItems.isEmpty else { return }
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
            speak("Back")
        case .primaryAction:
            impactFeedback.impactOccurred()
            vm.sendKeybind("space")
        case .checkScore:
            vm.sendKeybind("s")
        case .addBot:
            vm.sendKeybind("b")
        case .status:
            announceStatus()
        case .help:
            announceHelp()
        case .previousBuffer:
            vm.previousBuffer()
        case .nextBuffer:
            vm.nextBuffer()
        case .olderMessage:
            vm.olderMessage()
        case .newerMessage:
            vm.newerMessage()
        case .none:
            break
        }
    }

    // MARK: - Gesture Handlers

    @objc private func onSwipeRight() { dispatch(.oneFingerSwipeRight) }
    @objc private func onSwipeLeft() { dispatch(.oneFingerSwipeLeft) }
    @objc private func onSingleTap() { dispatch(.oneFingerSingleTap) }

    @objc private func onDoubleTap() { dispatch(.oneFingerDoubleTap) }

    @objc private func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        dispatch(.oneFingerLongPress)
    }

    private func onScrub() { dispatch(.twoFingerScrub) }
    @objc private func onTwoFingerDoubleTap() { dispatch(.twoFingerDoubleTap) }
    @objc private func onTwoFingerSwipeUp() { dispatch(.twoFingerSwipeUp) }
    @objc private func onTwoFingerSwipeDown() { dispatch(.twoFingerSwipeDown) }

    @objc private func onThreeFingerSwipeLeft() { dispatch(.threeFingerSwipeLeft) }
    @objc private func onThreeFingerSwipeRight() { dispatch(.threeFingerSwipeRight) }
    @objc private func onThreeFingerSwipeUp() { dispatch(.threeFingerSwipeUp) }
    @objc private func onThreeFingerSwipeDown() { dispatch(.threeFingerSwipeDown) }
    @objc private func onThreeFingerTap() { dispatch(.threeFingerTap) }

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

        let count = vm.menuItems.count

        // Auto-activate single-item menus (e.g., "Roll" or "Draw"
        // presented after a primary action). This makes two-finger
        // double-tap feel like one action instead of two.
        if count == 1 && count != lastMenuItemCount {
            lastMenuItemCount = count
            impactFeedback.impactOccurred()
            vm.activateMenuItem(0)
            return
        }

        lastMenuItemCount = count

        // Don't auto-announce on menu change — let server speech
        // (draw results, dice rolls, game announcements) come through
        // uninterrupted. The idle timer will announce if the user
        // doesn't interact within 8 seconds.
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
        speak("\(item.text). \(currentIndex + 1) of \(vm.menuItems.count)")
    }

    private func announceStatus() {
        guard let vm = viewModel else { return }
        let connected = vm.isConnected ? "Connected" : "Disconnected"
        let count = vm.menuItems.count
        if count == 0 {
            speak("\(connected). No menu items.")
        } else {
            let item = vm.menuItems[currentIndex].text
            speak("\(connected). Item \(currentIndex + 1) of \(count): \(item)")
        }
    }

    private func announceHelp() {
        guard let vm = viewModel else {
            speak("Not connected.")
            return
        }
        let count = vm.menuItems.count
        if count == 0 {
            speak("Waiting for menu. Swipe left or right when items appear.")
            return
        }

        // Build context-sensitive hint from what's in the menu
        let itemTexts = vm.menuItems.map { $0.text.lowercased() }
        var hints: [String] = []

        // Check for lobby indicators
        let isLobby = itemTexts.contains(where: { $0.contains("start") })
        if isLobby {
            hints.append("Double-tap to start game")
            hints.append("Two-finger swipe down to add bot")
        }

        // Check for card/game items
        let hasCards = itemTexts.contains(where: { $0.contains("of ") }) // "Ace of Spades"
        if hasCards {
            hints.append("Swipe to browse cards, double-tap to play")
            hints.append("Two-finger double-tap to draw")
        }

        // Check for dice games
        let hasDice = itemTexts.contains(where: { $0.contains("roll") || $0.contains("dice") })
        if hasDice {
            hints.append("Two-finger double-tap to roll")
        }

        // Always available
        hints.append("Two-finger scrub to go back")
        hints.append("Two-finger swipe up for score")

        // Fallback if nothing specific detected
        if hints.count <= 2 {
            hints.insert("\(count) items. Swipe to browse, double-tap to select", at: 0)
        }

        speak(hints.joined(separator: ". "))
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
        announceCurrentItem()
    }

    deinit {
        idleTimer?.invalidate()
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
                Button("Cancel") { viewModel.cancelEdit() }
                    .buttonStyle(.bordered)
                if !viewModel.editReadOnly {
                    Button("Submit") { viewModel.submitEdit() }
                        .buttonStyle(.borderedProminent)
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
                        .accessibilityHint("Slash for commands, dot for global chat")
                    Button { viewModel.sendChat() } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(viewModel.chatText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("Send")
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
        .onAppear { chatFocused = true }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Controls Sheet

private struct ControlsSheet: View {
    @ObservedObject var viewModel: MainViewModel
    var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Buffers") {
                    if let info = viewModel.currentBufferInfo {
                        Text(info).foregroundStyle(.secondary)
                    }
                    Button("Previous buffer") { viewModel.previousBuffer() }
                    Button("Next buffer") { viewModel.nextBuffer() }
                    Button("Older message") { viewModel.olderMessage() }
                    Button("Newer message") { viewModel.newerMessage() }
                    Button("Toggle mute") { viewModel.toggleBufferMute() }
                }
                Section("Volume") {
                    volumeRow("Music", viewModel.soundManager.musicVolume,
                              down: { viewModel.adjustMusicVolume(delta: -0.1) },
                              up: { viewModel.adjustMusicVolume(delta: 0.1) })
                    volumeRow("Ambience", viewModel.soundManager.ambienceVolume,
                              down: { viewModel.adjustAmbienceVolume(delta: -0.1) },
                              up: { viewModel.adjustAmbienceVolume(delta: 0.1) })
                }
                Section("Connection") {
                    Button("Ping server") { viewModel.sendPing() }
                    Button("Online users") { viewModel.requestOnlineUsers() }
                    Button(role: .destructive) {
                        viewModel.disconnect()
                        appState.returnToLogin()
                        dismiss()
                    } label: {
                        Text("Disconnect")
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
        .presentationDetents([.medium, .large])
    }

    private func volumeRow(_ label: String, _ value: Float, down: @escaping () -> Void, up: @escaping () -> Void) -> some View {
        HStack {
            Text("\(label): \(Int(value * 100))%")
            Spacer()
            Button { down() } label: { Image(systemName: "minus.circle") }
                .accessibilityLabel("\(label) down")
            Button { up() } label: { Image(systemName: "plus.circle") }
                .accessibilityLabel("\(label) up")
        }
    }
}

// MARK: - Help Sheet

private struct HelpSheet: View {
    @ObservedObject var gestureSettings: GestureSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
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
