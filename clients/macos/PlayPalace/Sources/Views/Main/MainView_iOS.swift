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
    @State private var showingChat = false
    @State private var showingControls = false
    @State private var showingHelp = false

    var body: some View {
        ZStack {
            if viewModel.isEditMode {
                EditOverlay(viewModel: viewModel)
            } else {
                DirectTouchGameView(viewModel: viewModel)
                    .ignoresSafeArea()
            }

            // Floating toolbar
            VStack {
                HStack(spacing: 10) {
                    toolbarButton("bubble.left.fill", "Chat") { showingChat = true }
                    toolbarButton("arrow.backward", "Back") { viewModel.sendEscape() }
                    Spacer()
                    toolbarButton("slider.horizontal.3", "Controls") { showingControls = true }
                    toolbarButton("questionmark.circle", "Help") { showingHelp = true }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                Spacer()
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingControls) {
            ControlsSheet(viewModel: viewModel, appState: appState)
        }
        .sheet(isPresented: $showingHelp) {
            HelpSheet()
        }
        .onAppear { viewModel.setup(appState: appState) }
        .onDisappear { viewModel.disconnect() }
    }

    private func toolbarButton(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
        }
        .accessibilityLabel(label)
    }
}

// MARK: - UIViewRepresentable Bridge

private struct DirectTouchGameView: UIViewRepresentable {
    @ObservedObject var viewModel: MainViewModel

    func makeUIView(context: Context) -> GameTouchView {
        let view = GameTouchView()
        view.viewModel = viewModel
        return view
    }

    func updateUIView(_ uiView: GameTouchView, context: Context) {
        uiView.viewModel = viewModel
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

    private let speech = SpeechQueue()
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
                UIAccessibilityCustomAction(name: "Primary action") { [weak self] _ in
                    self?.onTwoFingerDoubleTap(); return true
                },
                UIAccessibilityCustomAction(name: "Go back") { [weak self] _ in
                    self?.onScrub(); return true
                },
                UIAccessibilityCustomAction(name: "Check score") { [weak self] _ in
                    self?.viewModel?.sendKeybind("s"); return true
                },
                UIAccessibilityCustomAction(name: "Add bot") { [weak self] _ in
                    self?.viewModel?.sendKeybind("b"); return true
                },
                UIAccessibilityCustomAction(name: "Remove bot") { [weak self] _ in
                    self?.viewModel?.sendKeybind("shift+b"); return true
                },
                UIAccessibilityCustomAction(name: "Status") { [weak self] _ in
                    self?.announceStatus(); return true
                },
                UIAccessibilityCustomAction(name: "Previous buffer") { [weak self] _ in
                    self?.viewModel?.previousBuffer(); return true
                },
                UIAccessibilityCustomAction(name: "Next buffer") { [weak self] _ in
                    self?.viewModel?.nextBuffer(); return true
                },
                UIAccessibilityCustomAction(name: "Older message") { [weak self] _ in
                    self?.viewModel?.olderMessage(); return true
                },
                UIAccessibilityCustomAction(name: "Newer message") { [weak self] _ in
                    self?.viewModel?.newerMessage(); return true
                },
            ]
        }
        set {}
    }

    // MARK: - One Finger: Menu Navigation

    @objc private func onSwipeRight() {
        guard let vm = viewModel, !vm.menuItems.isEmpty else { return }
        if currentIndex < vm.menuItems.count - 1 {
            currentIndex += 1
        } else {
            speech.speak("End of list")
            return
        }
        vm.menuSelection = currentIndex
        selectionFeedback.selectionChanged()
        announceCurrentItem()
        resetIdleTimer()
    }

    @objc private func onSwipeLeft() {
        guard let vm = viewModel, !vm.menuItems.isEmpty else { return }
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            speech.speak("Beginning of list")
            return
        }
        vm.menuSelection = currentIndex
        selectionFeedback.selectionChanged()
        announceCurrentItem()
        resetIdleTimer()
    }

    @objc private func onDoubleTap() {
        guard let vm = viewModel, !vm.menuItems.isEmpty,
              currentIndex >= 0, currentIndex < vm.menuItems.count else {
            speech.speak("Nothing to select")
            notificationFeedback.notificationOccurred(.error)
            return
        }
        let item = vm.menuItems[currentIndex]
        impactFeedback.impactOccurred()
        vm.activateMenuItem(currentIndex)
        speech.speak(item.text)
        resetIdleTimer()
    }

    @objc private func onSingleTap() {
        announceCurrentItem()
        resetIdleTimer()
    }

    @objc private func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        announceStatus()
        resetIdleTimer()
    }

    // MARK: - Two Fingers: Game Actions

    private func onScrub() {
        guard let vm = viewModel else { return }
        impactFeedback.impactOccurred()
        vm.sendEscape()
        speech.speak("Back")
        resetIdleTimer()
    }

    @objc private func onTwoFingerDoubleTap() {
        guard let vm = viewModel else { return }
        impactFeedback.impactOccurred()
        vm.sendKeybind("space")
        resetIdleTimer()
    }

    @objc private func onTwoFingerSwipeUp() {
        guard let vm = viewModel else { return }
        vm.sendKeybind("s")
        resetIdleTimer()
    }

    @objc private func onTwoFingerSwipeDown() {
        guard let vm = viewModel else { return }
        vm.sendKeybind("b")
        resetIdleTimer()
    }

    // MARK: - Three Fingers: Buffer System

    @objc private func onThreeFingerSwipeLeft() {
        viewModel?.previousBuffer()
        resetIdleTimer()
    }

    @objc private func onThreeFingerSwipeRight() {
        viewModel?.nextBuffer()
        resetIdleTimer()
    }

    @objc private func onThreeFingerSwipeUp() {
        viewModel?.olderMessage()
        resetIdleTimer()
    }

    @objc private func onThreeFingerSwipeDown() {
        viewModel?.newerMessage()
        resetIdleTimer()
    }

    @objc private func onThreeFingerTap() {
        announceHelp()
        resetIdleTimer()
    }

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

        // Announce when menu content changes
        let count = vm.menuItems.count
        if count != lastMenuItemCount {
            lastMenuItemCount = count
            if count > 0 {
                let first = vm.menuItems[currentIndex].text
                speech.speak("\(count) items. \(first)")
            }
        }

        resetIdleTimer()
    }

    // MARK: - Speech Helpers

    private func announceCurrentItem() {
        guard let vm = viewModel, !vm.menuItems.isEmpty else {
            speech.speak("No items")
            return
        }
        let item = vm.menuItems[currentIndex]
        speech.speak("\(item.text). \(currentIndex + 1) of \(vm.menuItems.count)")
    }

    private func announceStatus() {
        guard let vm = viewModel else { return }
        let connected = vm.isConnected ? "Connected" : "Disconnected"
        let count = vm.menuItems.count
        if count == 0 {
            speech.speak("\(connected). No menu items.")
        } else {
            let item = vm.menuItems[currentIndex].text
            speech.speak("\(connected). Item \(currentIndex + 1) of \(count): \(item)")
        }
    }

    private func announceHelp() {
        speech.speak(
            "One finger: swipe left or right to browse, double-tap to select, tap to repeat, long press for status. " +
            "Two fingers: scrub to go back, double-tap for primary action, swipe up for score, swipe down to add bot. " +
            "Three fingers: swipe left or right for buffers, swipe up or down for messages, tap for this help."
        )
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

// MARK: - Speech Queue

/// Interruptible speech. New speech immediately cancels current utterance.
private final class SpeechQueue: NSObject, AVSpeechSynthesizerDelegate {
    private let synth = AVSpeechSynthesizer()

    override init() {
        super.init()
        synth.delegate = self
    }

    func speak(_ text: String) {
        synth.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synth.speak(utterance)
    }

    func stop() {
        synth.stopSpeaking(at: .immediate)
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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("One Finger — Menu") {
                    helpRow("Swipe right", "Next item")
                    helpRow("Swipe left", "Previous item")
                    helpRow("Double-tap", "Select current item")
                    helpRow("Single tap", "Repeat current item")
                    helpRow("Long press", "Detailed status")
                }
                Section("Two Fingers — Game Actions") {
                    helpRow("Scrub (zig-zag)", "Go back / escape")
                    helpRow("Double-tap", "Primary action (roll, draw)")
                    helpRow("Swipe up", "Check score")
                    helpRow("Swipe down", "Add bot (lobby)")
                }
                Section("Three Fingers — Buffers") {
                    helpRow("Swipe left", "Previous buffer")
                    helpRow("Swipe right", "Next buffer")
                    helpRow("Swipe up", "Older message")
                    helpRow("Swipe down", "Newer message")
                    helpRow("Tap", "Announce help")
                }
                Section("On-screen Buttons") {
                    helpRow("Chat", "Send messages to players")
                    helpRow("Back", "Go back (same as two-finger scrub)")
                    helpRow("Controls", "Volume, buffers, connection")
                    helpRow("Help", "This screen")
                }
                Section("Tips") {
                    Text("The app speaks everything itself. VoiceOver is optional but supported.")
                        .font(.callout).foregroundStyle(.secondary)
                    Text("After 8 seconds idle, the current item repeats.")
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
