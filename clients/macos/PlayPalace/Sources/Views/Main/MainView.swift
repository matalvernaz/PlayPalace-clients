import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        HSplitView {
            menuPanel
                .frame(minWidth: 200, idealWidth: 260, maxWidth: 400)
            rightPanel
        }
        .frame(minWidth: 700, minHeight: 500)
        .onAppear {
            viewModel.setup(appState: appState)
        }
        .onDisappear {
            viewModel.disconnect()
        }
        .focusedSceneValue(\.mainViewModel, viewModel)
        .background(KeyboardShortcutHandler(viewModel: viewModel))
    }

    // MARK: - Menu / Edit Panel

    private var menuPanel: some View {
        VStack(spacing: 0) {
            if viewModel.isEditMode {
                editModePanel
            } else {
                menuListPanel
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Game menu")
    }

    private var menuListPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Menu")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if let bufferInfo = viewModel.currentBufferInfo {
                    Text(bufferInfo)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .accessibilityLabel("Buffer: \(bufferInfo)")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            AccessibleMenuList(
                items: viewModel.menuItems,
                selection: $viewModel.menuSelection,
                onActivate: viewModel.activateMenuItem,
                onKeyEvent: viewModel.handleMenuKeyEvent,
                soundManager: viewModel.soundManager
            )
        }
    }

    private var editModePanel: some View {
        VStack(spacing: 8) {
            Text(viewModel.editPrompt)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)

            if viewModel.editMultiline {
                TextEditor(text: $viewModel.editText)
                    .font(.body)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .disabled(viewModel.editReadOnly)
                    .accessibilityLabel(viewModel.editPrompt)
                    .accessibilityValue(viewModel.editText)
                    .focused($editFocused)
            } else {
                TextField(viewModel.editPrompt, text: $viewModel.editText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 12)
                    .disabled(viewModel.editReadOnly)
                    .onSubmit { viewModel.submitEdit() }
                    .accessibilityLabel(viewModel.editPrompt)
                    .focused($editFocused)
            }

            HStack {
                Button("Cancel") { viewModel.cancelEdit() }
                    .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                if !viewModel.editReadOnly {
                    Button("Submit") { viewModel.submitEdit() }
                        .keyboardShortcut(.return, modifiers: [])
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    @FocusState private var editFocused: Bool

    // MARK: - Right Panel (History + Chat)

    private var rightPanel: some View {
        VStack(spacing: 0) {
            historyView
            Divider()
            chatBar
        }
    }

    private var historyView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("History")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                connectionBadge
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(viewModel.historyItems) { item in
                            Text(item.text)
                                .font(.system(.body, design: .default))
                                .textSelection(.enabled)
                                .id(item.id)
                                .accessibilityLabel(item.text)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                .onChange(of: viewModel.historyItems.count) {
                    if let last = viewModel.historyItems.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .accessibilityLabel("Message history")
        }
    }

    private var chatBar: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.chatMode == .table ? "bubble.left.fill" : "globe")
                .foregroundStyle(.secondary)
                .accessibilityLabel(viewModel.chatMode == .table ? "Table chat" : "Global chat")

            TextField("Type a message", text: $viewModel.chatText)
                .textFieldStyle(.roundedBorder)
                .onSubmit { viewModel.sendChat() }
                .accessibilityLabel("Chat input. \(viewModel.chatMode == .table ? "Table" : "Global") chat mode")
                .accessibilityHint("Press Enter to send. Start with / for commands, . for global chat")

            Button(action: viewModel.sendChat) {
                Image(systemName: "paperplane.fill")
            }
            .disabled(viewModel.chatText.isEmpty)
            .accessibilityLabel("Send message")
        }
        .padding(10)
    }

    private var connectionBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(viewModel.isConnected ? .green : .red)
                .frame(width: 8, height: 8)
            Text(viewModel.isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.isConnected ? "Connected to server" : "Disconnected from server")
    }
}

// MARK: - Focus Key

struct MainViewModelKey: FocusedValueKey {
    typealias Value = MainViewModel
}

extension FocusedValues {
    var mainViewModel: MainViewModel? {
        get { self[MainViewModelKey.self] }
        set { self[MainViewModelKey.self] = newValue }
    }
}
