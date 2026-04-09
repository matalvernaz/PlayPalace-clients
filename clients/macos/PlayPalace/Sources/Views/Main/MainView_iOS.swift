#if os(iOS)
import SwiftUI
import UIKit

/// The main game view for iOS.
/// Layout from top to bottom: status bar, menu/edit area, action bar, chat bar.
/// Provides toolbar buttons for buffer navigation, volume, and ping.
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MainViewModel()
    @FocusState private var chatFieldFocused: Bool
    @FocusState private var editFieldFocused: Bool
    @State private var showingVolumeControls = false
    @State private var showingBufferBrowser = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statusBar
                Divider()
                gameArea
                Divider()
                ActionBar { key in
                    if key == "escape" {
                        viewModel.sendEscape()
                    } else {
                        viewModel.sendKeybind(key)
                    }
                }
                Divider()
                chatBar
            }
            .navigationTitle("PlayPalace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        viewModel.previousBuffer()
                    } label: {
                        Label("Previous buffer", systemImage: "chevron.left.square")
                    }
                    .accessibilityLabel("Previous buffer")
                    .accessibilityHint("Switch to the previous message buffer")

                    Button {
                        viewModel.nextBuffer()
                    } label: {
                        Label("Next buffer", systemImage: "chevron.right.square")
                    }
                    .accessibilityLabel("Next buffer")
                    .accessibilityHint("Switch to the next message buffer")
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingVolumeControls = true
                    } label: {
                        Label("Volume", systemImage: "speaker.wave.2")
                    }
                    .accessibilityLabel("Volume controls")
                    .accessibilityHint("Adjust music and ambience volume")

                    Button {
                        viewModel.sendPing()
                    } label: {
                        Label("Ping", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .accessibilityLabel("Ping server")
                    .accessibilityHint("Check the connection latency to the server")

                    Button {
                        viewModel.disconnect()
                        appState.returnToLogin()
                    } label: {
                        Label("Disconnect", systemImage: "xmark.circle")
                    }
                    .accessibilityLabel("Disconnect")
                    .accessibilityHint("Disconnect from the server and return to login")
                }
            }
            .sheet(isPresented: $showingVolumeControls) {
                VolumeControlSheet_iOS(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.setup(appState: appState)
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack(spacing: 8) {
            // Connection indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(viewModel.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(viewModel.isConnected ? "Connected" : "Disconnected")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(viewModel.isConnected ? "Connected to server" : "Disconnected from server")

            Spacer()

            // Buffer info
            if let bufferInfo = viewModel.currentBufferInfo {
                Text(bufferInfo)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .accessibilityLabel("Current buffer: \(bufferInfo)")
            }

            // Buffer mute toggle
            Button {
                viewModel.toggleBufferMute()
            } label: {
                Image(systemName: "speaker.slash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Toggle buffer mute")
            .accessibilityHint("Mute or unmute the current message buffer")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - Game Area (Menu or Edit)

    private var gameArea: some View {
        VStack(spacing: 0) {
            if viewModel.isEditMode {
                editPanel
            } else {
                menuArea
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Menu Area

    private var menuArea: some View {
        VStack(spacing: 0) {
            // History messages (scrolling area)
            historyView

            Divider()

            // Menu list
            MenuList_iOS(
                items: viewModel.menuItems,
                selection: $viewModel.menuSelection,
                onActivate: { index in
                    viewModel.activateMenuItem(index)
                }
            )
            .frame(maxHeight: .infinity)
        }
    }

    // MARK: - History View

    private var historyView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("History")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()

                // Older/newer message navigation
                Button {
                    viewModel.olderMessage()
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.caption)
                }
                .accessibilityLabel("Older message")
                .accessibilityHint("Read the previous message in the current buffer")

                Button {
                    viewModel.newerMessage()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .accessibilityLabel("Newer message")
                .accessibilityHint("Read the next message in the current buffer")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(viewModel.historyItems) { item in
                            Text(item.text)
                                .font(.system(.caption, design: .default))
                                .textSelection(.enabled)
                                .id(item.id)
                                .accessibilityLabel(item.text)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)
                }
                .onChange(of: viewModel.historyItems.count) { _, _ in
                    if let last = viewModel.historyItems.last {
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(maxHeight: 160)
            .accessibilityLabel("Message history")
        }
    }

    // MARK: - Edit Panel

    private var editPanel: some View {
        VStack(spacing: 12) {
            Spacer()

            Text(viewModel.editPrompt)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .accessibilityAddTraits(.isHeader)

            if viewModel.editMultiline {
                TextEditor(text: $viewModel.editText)
                    .font(.body)
                    .frame(minHeight: 120)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .disabled(viewModel.editReadOnly)
                    .focused($editFieldFocused)
                    .accessibilityLabel(viewModel.editPrompt)
                    .accessibilityValue(viewModel.editText)
                    .accessibilityHint(viewModel.editReadOnly ? "Read only" : "Enter your text")
            } else {
                TextField(viewModel.editPrompt, text: $viewModel.editText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                    .disabled(viewModel.editReadOnly)
                    .focused($editFieldFocused)
                    .onSubmit { viewModel.submitEdit() }
                    .accessibilityLabel(viewModel.editPrompt)
                    .accessibilityHint(viewModel.editReadOnly ? "Read only" : "Enter your text and tap Submit")
            }

            HStack(spacing: 16) {
                Button(role: .cancel) {
                    viewModel.cancelEdit()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Cancel editing")
                .accessibilityHint("Discard changes and go back")

                if !viewModel.editReadOnly {
                    Button {
                        viewModel.submitEdit()
                    } label: {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Submit text")
                    .accessibilityHint("Send your entered text to the server")
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .onAppear {
            editFieldFocused = true
        }
    }

    // MARK: - Chat Bar

    private var chatBar: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.chatMode == .table ? "bubble.left.fill" : "globe")
                .foregroundStyle(.secondary)
                .font(.system(size: 16))
                .accessibilityLabel(viewModel.chatMode == .table ? "Table chat mode" : "Global chat mode")

            TextField("Type a message", text: $viewModel.chatText)
                .textFieldStyle(.roundedBorder)
                .focused($chatFieldFocused)
                .onSubmit { viewModel.sendChat() }
                .submitLabel(.send)
                .accessibilityLabel("Chat message")
                .accessibilityHint(
                    "Type a message and tap Send. Start with slash for commands, dot for global chat. Currently in \(viewModel.chatMode == .table ? "table" : "global") chat mode."
                )

            Button(action: {
                viewModel.sendChat()
                chatFieldFocused = false
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
            }
            .disabled(viewModel.chatText.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Send message")
            .accessibilityHint(viewModel.chatText.isEmpty ? "Type a message first" : "Send the current message")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

// MARK: - Volume Control Sheet

/// A sheet providing music and ambience volume controls.
private struct VolumeControlSheet_iOS: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Music Volume: \(Int(viewModel.soundManager.musicVolume * 100))%")
                            .font(.body)
                            .accessibilityHidden(true)
                        HStack(spacing: 16) {
                            Button {
                                viewModel.adjustMusicVolume(delta: -0.1)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                            }
                            .accessibilityLabel("Decrease music volume")
                            .accessibilityHint("Reduce music volume by 10 percent")

                            ProgressView(value: viewModel.soundManager.musicVolume)
                                .accessibilityLabel("Music volume \(Int(viewModel.soundManager.musicVolume * 100)) percent")

                            Button {
                                viewModel.adjustMusicVolume(delta: 0.1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .accessibilityLabel("Increase music volume")
                            .accessibilityHint("Increase music volume by 10 percent")
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Music", systemImage: "music.note")
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ambience Volume: \(Int(viewModel.soundManager.ambienceVolume * 100))%")
                            .font(.body)
                            .accessibilityHidden(true)
                        HStack(spacing: 16) {
                            Button {
                                viewModel.adjustAmbienceVolume(delta: -0.1)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                            }
                            .accessibilityLabel("Decrease ambience volume")
                            .accessibilityHint("Reduce ambience volume by 10 percent")

                            ProgressView(value: viewModel.soundManager.ambienceVolume)
                                .accessibilityLabel("Ambience volume \(Int(viewModel.soundManager.ambienceVolume * 100)) percent")

                            Button {
                                viewModel.adjustAmbienceVolume(delta: 0.1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .accessibilityLabel("Increase ambience volume")
                            .accessibilityHint("Increase ambience volume by 10 percent")
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Ambience", systemImage: "leaf")
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Volume Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityLabel("Close volume controls")
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppState())
    }
}
#endif

#endif
