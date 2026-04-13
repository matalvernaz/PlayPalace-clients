import SwiftUI
import Combine

enum ChatMode: String {
    case table, global
}

@MainActor
final class MainViewModel: ObservableObject, WebSocketDelegate {
    // MARK: - Published State

    @Published var menuItems: [MenuItem] = []
    @Published var menuSelection: Int? = 0
    @Published var historyItems: [BufferItem] = []
    @Published var chatText = ""
    @Published var chatMode: ChatMode = .table
    @Published var isConnected = false
    @Published var isEditMode = false
    @Published var editPrompt = ""
    @Published var editText = ""
    @Published var editMultiline = false
    @Published var editReadOnly = false
    @Published var currentBufferInfo: String?
    @Published var gridEnabled = false
    @Published var gridWidth = 1
    @Published var helpText: String?

    // MARK: - Internal State

    private(set) var soundManager = SoundManager()
    private(set) var speechManager = SpeechManager()
    private var bufferSystem = BufferSystem()
    private var webSocket: WebSocketClient?
    private var appState: AppState?

    private var currentMenuID: String?
    private var currentMenuItemIDs: [String?] = []
    private var multiletter = true
    private var escapeBehavior = "keybind"
    private var editCallback: ((String) -> Void)?
    private var pingStartTime: Date?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 30
    private var expectingReconnect = false
    private var credentials: Credentials?

    // MARK: - Setup

    func setup(appState: AppState) {
        self.appState = appState
        guard let creds = appState.credentials else { return }
        self.credentials = creds

        // Restore muted buffers
        let prefs = appState.configManager.loadPreferences()
        if let muted = prefs["muted_buffers"] as? [String] {
            bufferSystem.restoreMuted(Set(muted))
        }

        connect(creds)
    }

    private func connect(_ creds: Credentials) {
        webSocket = WebSocketClient(delegate: self)
        soundManager.playMusic("connectloop.ogg")
        addHistory("Connecting to \(creds.serverURL)...", buffer: "activity")

        webSocket?.connect(
            url: creds.serverURL,
            username: creds.username,
            password: creds.password,
            refreshToken: creds.refreshToken,
            refreshExpiresAt: creds.refreshExpiresAt
        )
    }

    func disconnect() {
        webSocket?.disconnect()
        soundManager.stopMusic(fade: false)
        soundManager.removeAllPlaylists()
    }

    // MARK: - WebSocketDelegate

    nonisolated func onPacketReceived(type: String, packet: [String: Any]) {
        Task { @MainActor in
            handlePacket(type: type, packet: packet)
        }
    }

    nonisolated func onConnectionLost() {
        Task { @MainActor in
            isConnected = false
            if !expectingReconnect {
                addHistory("Connection lost!", buffer: "activity")
                speechManager.speak("Connection lost")
            }
        }
    }

    nonisolated func onConnectionError(_ message: String) {
        Task { @MainActor in
            addHistory(message, buffer: "activity")
            speechManager.speak(message)
        }
    }

    // MARK: - Packet Dispatch

    private func handlePacket(type: String, packet: [String: Any]) {
        switch type {
        case "authorize_success":
            handleAuthorizeSuccess(packet)
        case "speak":
            handleSpeak(packet)
        case "menu":
            handleMenu(packet)
        case "request_input":
            handleRequestInput(packet)
        case "document_editor":
            handleDocumentEditor(packet)
        case "clear_ui":
            handleClearUI()
        case "chat":
            handleChat(packet)
        case "play_sound":
            handlePlaySound(packet)
        case "play_music":
            handlePlayMusic(packet)
        case "play_ambience":
            handlePlayAmbience(packet)
        case "stop_ambience":
            soundManager.stopAmbience()
        case "add_playlist":
            handleAddPlaylist(packet)
        case "start_playlist":
            soundManager.startPlaylist(packet["playlist_id"] as? String ?? "music_playlist")
        case "remove_playlist":
            soundManager.removePlaylist(packet["playlist_id"] as? String ?? "music_playlist")
        case "get_playlist_duration":
            handleGetPlaylistDuration(packet)
        case "disconnect":
            handleDisconnect(packet)
        case "pong":
            handlePong()
        case "game_list":
            handleGameList(packet)
        case "server_status":
            handleServerStatus(packet)
        case "table_create":
            handleTableCreate(packet)
        case "update_options_lists":
            handleUpdateOptionsLists(packet)
        case "open_client_options", "open_server_options":
            break // Options dialogs not yet implemented
        default:
            break
        }
    }

    // MARK: - Packet Handlers

    private func handleAuthorizeSuccess(_ packet: [String: Any]) {
        isConnected = true
        reconnectAttempts = 0
        expectingReconnect = false

        let version = packet["version"] as? String ?? "unknown"
        let username = packet["username"] as? String ?? credentials?.username ?? "Guest"
        soundManager.stopMusic(fade: false)
        soundManager.play("welcome.ogg")
        addHistory("Connected as \(username) (server \(version))", buffer: "activity")

        // Save refresh token
        if let refreshToken = packet["refresh_token"] as? String,
           let serverID = credentials?.serverID,
           let accountID = credentials?.accountID {
            let refreshExpires = packet["refresh_expires_at"] as? Int
            appState?.configManager.updateAccount(
                serverID: serverID, accountID: accountID,
                refreshToken: refreshToken, refreshExpiresAt: refreshExpires
            )
        }
    }

    private func handleSpeak(_ packet: [String: Any]) {
        let text = packet["text"] as? String ?? ""
        let buffer = packet["buffer"] as? String ?? "misc"
        let muted = packet["muted"] as? Bool ?? false
        guard !text.isEmpty else { return }
        addHistory(text, buffer: buffer, speak: !muted)
    }

    private func handleMenu(_ packet: [String: Any]) {
        let data = MenuPacketData(from: packet)

        multiletter = data.multiletter
        escapeBehavior = data.escapeBehavior
        gridEnabled = data.gridEnabled
        gridWidth = max(1, data.gridWidth)
        helpText = data.helpText

        // Exit edit mode if needed
        if isEditMode { cancelEdit() }

        let isSameMenu = currentMenuID == data.menuID
        currentMenuID = data.menuID
        currentMenuItemIDs = data.items.map(\.id)

        menuItems = data.items

        if let pos = data.position, pos >= 0, pos < data.items.count {
            menuSelection = pos
        } else if !isSameMenu {
            menuSelection = data.items.isEmpty ? nil : 0
        }

        // Play selection sound if requested
        if packet["play_selection_sound"] as? Bool == true {
            if let pos = data.position, pos >= 0, pos < data.items.count,
               let sound = data.items[pos].sound {
                soundManager.play(sound)
            } else {
                soundManager.playMenuClick()
            }
        }

        // Announce new menu to VoiceOver
        if !isSameMenu, let sel = menuSelection, sel < data.items.count {
            speechManager.speak(data.items[sel].text)
        }
    }

    private func handleRequestInput(_ packet: [String: Any]) {
        let prompt = packet["prompt"] as? String ?? "Enter text:"
        let inputID = packet["input_id"] as? String
        let defaultValue = packet["default_value"] as? String ?? ""
        let multiline = packet["multiline"] as? Bool ?? false
        let readOnly = packet["read_only"] as? Bool ?? false

        switchToEditMode(
            prompt: prompt,
            defaultValue: defaultValue,
            multiline: multiline,
            readOnly: readOnly
        ) { [weak self] text in
            var pkt: [String: Any] = ["type": "editbox", "text": text]
            if let inputID { pkt["input_id"] = inputID }
            self?.webSocket?.send(pkt)
        }
    }

    private func handleDocumentEditor(_ packet: [String: Any]) {
        let dialogID = packet["dialog_id"] as? String ?? ""
        let content = packet["content"] as? String ?? ""
        let prompt = packet["prompt"] as? String ?? "Edit document"

        switchToEditMode(
            prompt: prompt,
            defaultValue: content,
            multiline: true,
            readOnly: false
        ) { [weak self] text in
            self?.webSocket?.send(ClientPacket.documentEditorResponse(
                dialogID: dialogID, action: text.isEmpty ? "cancel" : "save", content: text
            ))
        }
    }

    private func handleClearUI() {
        menuItems = []
        currentMenuID = nil
        currentMenuItemIDs = []
        gridEnabled = false
        gridWidth = 1
        helpText = nil
        if isEditMode { cancelEdit() }
        soundManager.removeAllPlaylists()
        soundManager.stopMusic(fade: true)
        soundManager.stopAmbience(force: false)
    }

    private func handleChat(_ packet: [String: Any]) {
        let convo = packet["convo"] as? String ?? "local"
        let sender = packet["sender"] as? String ?? ""
        let message = packet["message"] as? String ?? ""

        let formatted: String
        if convo == "global" {
            formatted = "\(sender) globally: \(message)"
        } else {
            formatted = "\(sender): \(message)"
        }

        let sound = convo == "local" ? "chatlocal.ogg" : "chat.ogg"
        soundManager.play(sound)
        speechManager.speak(formatted)
        addHistory(formatted, buffer: "chats", speak: false)
    }

    private func handlePlaySound(_ packet: [String: Any]) {
        let name = packet["name"] as? String ?? ""
        let volume = Float(packet["volume"] as? Int ?? 100) / 100.0
        let pan = Float(packet["pan"] as? Int ?? 0) / 100.0
        let pitch = Float(packet["pitch"] as? Int ?? 100) / 100.0
        if !name.isEmpty { soundManager.play(name, volume: volume, pan: pan, pitch: pitch) }
    }

    private func handlePlayMusic(_ packet: [String: Any]) {
        let name = packet["name"] as? String ?? ""
        let looping = packet["looping"] as? Bool ?? true
        if !name.isEmpty { soundManager.playMusic(name, looping: looping) }
    }

    private func handlePlayAmbience(_ packet: [String: Any]) {
        let intro = packet["intro"] as? String
        let loop = packet["loop"] as? String ?? ""
        let outro = packet["outro"] as? String
        if !loop.isEmpty { soundManager.playAmbience(intro: intro, loop: loop, outro: outro) }
    }

    private func handleAddPlaylist(_ packet: [String: Any]) {
        let id = packet["playlist_id"] as? String ?? "music_playlist"
        let tracks = packet["tracks"] as? [String] ?? []
        let audioType = packet["audio_type"] as? String ?? "music"
        let shuffle = packet["shuffle_tracks"] as? Bool ?? false
        let repeats = packet["repeats"] as? Int ?? 1
        let autoStart = packet["auto_start"] as? Bool ?? true
        let autoRemove = packet["auto_remove"] as? Bool ?? true
        if !tracks.isEmpty {
            soundManager.addPlaylist(
                id: id, tracks: tracks, audioType: audioType,
                shuffle: shuffle, repeats: repeats,
                autoStart: autoStart, autoRemove: autoRemove
            )
        }
    }

    private func handleGetPlaylistDuration(_ packet: [String: Any]) {
        let playlistID = packet["playlist_id"] as? String ?? "music_playlist"
        let durationType = packet["duration_type"] as? String ?? "total"
        let requestID = packet["request_id"]

        // Playlists don't track duration in this implementation yet,
        // send 0 as a response
        if let requestID {
            webSocket?.send(ClientPacket.playlistDurationResponse(
                requestID: requestID, playlistID: playlistID,
                durationType: durationType, duration: 0
            ))
        }
    }

    private func handleDisconnect(_ packet: [String: Any]) {
        let shouldReconnect = packet["reconnect"] as? Bool ?? false
        let showMessage = packet["show_message"] as? Bool ?? false
        let returnToLogin = packet["return_to_login"] as? Bool ?? false
        let retryAfter = packet["retry_after"] as? Int
        let message = packet["message"] as? String

        if shouldReconnect {
            let delay = max(1, retryAfter ?? 3)
            expectingReconnect = true
            addHistory("Server is restarting. Reconnecting in \(delay) seconds...", buffer: "activity")
            speechManager.speak("Reconnecting in \(delay) seconds")
            Task {
                try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                attemptReconnect()
            }
        } else if showMessage {
            let msg = message ?? "Disconnected by server."
            addHistory(msg, buffer: "activity")
            speechManager.speak(msg)
            if returnToLogin {
                appState?.returnToLogin()
            }
        } else {
            speechManager.speak("Disconnected")
            appState?.returnToLogin()
        }
    }

    private func handlePong() {
        if let start = pingStartTime {
            let ms = Int(Date().timeIntervalSince(start) * 1000)
            pingStartTime = nil
            soundManager.play("pingstop.ogg")
            speechManager.speak("Ping: \(ms)ms")
        }
    }

    private func handleGameList(_ packet: [String: Any]) {
        let games = packet["games"] as? [[String: Any]] ?? []
        if games.isEmpty {
            addHistory("No games available")
        } else {
            var text = "Available games:"
            for game in games {
                let id = game["id"] as? String ?? ""
                let name = game["name"] as? String ?? ""
                let type = game["type"] as? String ?? ""
                let players = game["players"] as? Int ?? 0
                let maxPlayers = game["max_players"] as? Int ?? 0
                text += "\n\(id): \(name) (\(type)) - \(players)/\(maxPlayers) players"
            }
            addHistory(text)
        }
    }

    private func handleServerStatus(_ packet: [String: Any]) {
        let message = packet["message"] as? String ?? "Server is temporarily unavailable."
        addHistory(message, buffer: "activity")
        speechManager.speak(message, interrupt: false)
    }

    private func handleTableCreate(_ packet: [String: Any]) {
        let host = packet["host"] as? String ?? ""
        let game = packet["game"] as? String ?? ""
        soundManager.play("notify.ogg")
        addHistory("\(host) is hosting \(game).", buffer: "activity")
    }

    private func handleUpdateOptionsLists(_ packet: [String: Any]) {
        // Send client options back to server
        if isConnected {
            webSocket?.send(ClientPacket.clientOptions(options: [:]))
        }
    }

    // MARK: - User Actions

    func activateMenuItem(_ index: Int) {
        guard index >= 0, index < menuItems.count, isConnected else { return }
        soundManager.playMenuEnter()
        var packet = ClientPacket.menuSelection(
            selection: index + 1,
            menuID: currentMenuID
        )
        if index < currentMenuItemIDs.count, let id = currentMenuItemIDs[index] {
            packet["selection_id"] = id
        }
        webSocket?.send(packet)
    }

    func sendChat() {
        let text = chatText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, isConnected else { return }

        if text.hasPrefix("/") {
            let parts = text.dropFirst().split(separator: " ", maxSplits: 1)
            let command = String(parts.first ?? "")
            let args = parts.count > 1 ? String(parts[1]) : ""
            webSocket?.send(ClientPacket.slashCommand(command: command, args: args))
        } else if text.hasPrefix(".") {
            let parts = text.dropFirst().split(separator: " ", maxSplits: 1)
            let message = parts.count > 1 ? String(parts[1]) : ""
            if !message.isEmpty {
                webSocket?.send(ClientPacket.chat(message: message, convo: "global"))
            }
        } else {
            webSocket?.send(ClientPacket.chat(message: text, convo: "local"))
        }
        chatText = ""
    }

    func handleMenuKeyEvent(_ key: KeyEquivalent, modifiers: EventModifiers) -> Bool {
        // Map key events to server keybinds
        let keyName: String?
        switch key {
        case .escape, .delete:
            return handleEscapeKey()
        case .space:
            keyName = "space"
        case .return:
            if modifiers.contains(.command) || modifiers.contains(.shift) || modifiers.contains(.option) {
                keyName = "enter"
            } else {
                return false
            }
        case .upArrow:
            if modifiers.contains(.command) || menuItems.isEmpty {
                keyName = "up"
            } else { return false }
        case .downArrow:
            if modifiers.contains(.command) || menuItems.isEmpty {
                keyName = "down"
            } else { return false }
        case .leftArrow:
            if modifiers.contains(.command) || menuItems.isEmpty {
                keyName = "left"
            } else { return false }
        case .rightArrow:
            if modifiers.contains(.command) || menuItems.isEmpty {
                keyName = "right"
            } else { return false }
        default:
            let char = String(key.character)
            if char.first?.isLetter == true {
                keyName = char.lowercased()
            } else if char.first?.isNumber == true {
                keyName = char
            } else {
                return false
            }
        }

        guard let name = keyName, isConnected else { return false }

        let sel = menuSelection
        var packet = ClientPacket.keybind(
            key: name,
            control: modifiers.contains(.command),
            alt: modifiers.contains(.option),
            shift: modifiers.contains(.shift),
            menuID: currentMenuID,
            menuIndex: sel != nil ? sel! + 1 : nil
        )
        if let sel, sel < currentMenuItemIDs.count, let id = currentMenuItemIDs[sel] {
            packet["menu_item_id"] = id
        }
        webSocket?.send(packet)
        return true
    }

    private func handleEscapeKey() -> Bool {
        guard isConnected else { return false }
        switch escapeBehavior {
        case "select_last_option":
            if !menuItems.isEmpty {
                soundManager.playMenuEnter()
                var packet = ClientPacket.menuSelection(
                    selection: menuItems.count,
                    menuID: currentMenuID
                )
                let lastIdx = menuItems.count - 1
                if lastIdx < currentMenuItemIDs.count, let id = currentMenuItemIDs[lastIdx] {
                    packet["selection_id"] = id
                }
                webSocket?.send(packet)
            }
            return true
        case "escape_event":
            webSocket?.send(ClientPacket.escape(menuID: currentMenuID))
            return true
        default:
            return false
        }
    }

    // MARK: - iOS Keybind Helpers

    /// Sends a keybind packet for the given key name (e.g. "r", "space", "enter", "up").
    /// Used by the iOS ActionBar and other touch-based controls.
    func sendKeybind(_ key: String) {
        guard isConnected else { return }
        let sel = menuSelection
        var packet = ClientPacket.keybind(
            key: key,
            menuID: currentMenuID,
            menuIndex: sel != nil ? sel! + 1 : nil
        )
        if let sel, sel < currentMenuItemIDs.count, let id = currentMenuItemIDs[sel] {
            packet["menu_item_id"] = id
        }
        webSocket?.send(packet)
    }

    /// Sends an escape action, respecting the current escape behavior set by the server.
    func sendEscape() {
        _ = handleEscapeKey()
    }

    // MARK: - Edit Mode

    func switchToEditMode(prompt: String, defaultValue: String, multiline: Bool, readOnly: Bool, callback: @escaping (String) -> Void) {
        editPrompt = prompt
        editText = defaultValue
        editMultiline = multiline
        editReadOnly = readOnly
        editCallback = callback
        isEditMode = true
        speechManager.speak(prompt)
    }

    func submitEdit() {
        let text = editText
        editCallback?(text)
        exitEditMode()
    }

    func cancelEdit() {
        editCallback?("")
        exitEditMode()
    }

    private func exitEditMode() {
        isEditMode = false
        editCallback = nil
        editText = ""
        editPrompt = ""
    }

    // MARK: - Volume Controls

    func adjustMusicVolume(delta: Float) {
        let newVol = max(0, min(1, soundManager.musicVolume + delta))
        soundManager.setMusicVolume(newVol)
        let pct = Int(newVol * 100)
        speechManager.speak("Music: \(pct)%")
    }

    func adjustAmbienceVolume(delta: Float) {
        let newVol = max(0, min(1, soundManager.ambienceVolume + delta))
        soundManager.setAmbienceVolume(newVol)
        let pct = Int(newVol * 100)
        speechManager.speak("Ambience: \(pct)%")
    }

    // MARK: - Buffer Navigation

    func previousBuffer() {
        let info = bufferSystem.previousBuffer()
        currentBufferInfo = info
        speechManager.speak(info, interrupt: true)
    }

    func nextBuffer() {
        let info = bufferSystem.nextBuffer()
        currentBufferInfo = info
        speechManager.speak(info, interrupt: true)
    }

    func olderMessage() {
        if let msg = bufferSystem.olderMessage() {
            speechManager.speak(msg, interrupt: true)
        }
    }

    func newerMessage() {
        if let msg = bufferSystem.newerMessage() {
            speechManager.speak(msg, interrupt: true)
        }
    }

    func toggleBufferMute() {
        let muted = bufferSystem.toggleMute()
        let name = bufferSystem.currentBufferName
        let status = muted ? "muted" : "unmuted"
        speechManager.speak("Buffer \(name) \(status)", interrupt: true)
        appState?.configManager.saveMutedBuffers(bufferSystem.mutedBufferNames())
    }

    // MARK: - Ping

    func sendPing() {
        pingStartTime = Date()
        soundManager.play("pingstart.ogg")
        webSocket?.send(ClientPacket.ping())
    }

    // MARK: - Online Users

    func requestOnlineUsers() {
        guard isConnected else { return }
        webSocket?.send(ClientPacket.listOnline())
    }

    func requestOnlineUsersWithGames() {
        guard isConnected else { return }
        webSocket?.send(ClientPacket.listOnlineWithGames())
    }

    // MARK: - Chat Mode Toggle

    func toggleTableChatMute() {
        speechManager.speak("Table chat toggled")
    }

    func toggleGlobalChatMute() {
        speechManager.speak("Global chat toggled")
    }

    // MARK: - Reconnect

    private func attemptReconnect() {
        guard let creds = credentials else { return }
        reconnectAttempts += 1
        if reconnectAttempts > maxReconnectAttempts {
            expectingReconnect = false
            speechManager.speak("Failed to reconnect after multiple attempts")
            appState?.returnToLogin()
            return
        }
        addHistory("Reconnecting... (attempt \(reconnectAttempts))", buffer: "activity")
        webSocket?.disconnect()
        connect(creds)
    }

    // MARK: - History

    func addHistory(_ text: String, buffer: String = "misc", speak: Bool = true) {
        let item = BufferItem(text)
        historyItems.append(item)
        bufferSystem.addItem(text, buffer: buffer)

        if speak && !bufferSystem.isMuted(buffer) {
            speechManager.speak(text, interrupt: false)
        }
    }
}
