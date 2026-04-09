import Foundation
#if os(iOS)
import UIKit
#endif

// MARK: - Client → Server Packets

enum ClientPacket {
    static func authorize(
        username: String,
        password: String? = nil,
        sessionToken: String? = nil,
        clientType: String = "Desktop",
        platform: String = Self.platformString()
    ) -> [String: Any] {
        var packet: [String: Any] = [
            "type": "authorize",
            "username": username,
            "major": 11,
            "minor": 0,
            "patch": 0,
            "client_type": clientType,
            "platform": platform,
        ]
        if let sessionToken {
            packet["session_token"] = sessionToken
        } else if let password {
            packet["password"] = password
        }
        return packet
    }

    static func refreshSession(
        refreshToken: String,
        username: String,
        clientType: String = "Desktop",
        platform: String = Self.platformString()
    ) -> [String: Any] {
        [
            "type": "refresh_session",
            "refresh_token": refreshToken,
            "username": username,
            "client_type": clientType,
            "platform": platform,
        ]
    }

    static func register(
        username: String,
        password: String,
        email: String? = nil,
        bio: String? = nil
    ) -> [String: Any] {
        var packet: [String: Any] = [
            "type": "register",
            "username": username,
            "password": password,
        ]
        if let email { packet["email"] = email }
        if let bio { packet["bio"] = bio }
        return packet
    }

    static func menuSelection(
        selection: Int,
        menuID: String? = nil,
        selectionID: String? = nil
    ) -> [String: Any] {
        var packet: [String: Any] = [
            "type": "menu",
            "selection": selection,
        ]
        if let menuID { packet["menu_id"] = menuID }
        if let selectionID { packet["selection_id"] = selectionID }
        return packet
    }

    static func keybind(
        key: String,
        control: Bool = false,
        alt: Bool = false,
        shift: Bool = false,
        menuID: String? = nil,
        menuIndex: Int? = nil,
        menuItemID: String? = nil
    ) -> [String: Any] {
        var packet: [String: Any] = [
            "type": "keybind",
            "key": key,
            "control": control,
            "alt": alt,
            "shift": shift,
        ]
        if let menuID { packet["menu_id"] = menuID }
        if let menuIndex { packet["menu_index"] = menuIndex }
        if let menuItemID { packet["menu_item_id"] = menuItemID }
        return packet
    }

    static func escape(menuID: String? = nil) -> [String: Any] {
        var packet: [String: Any] = ["type": "escape"]
        if let menuID { packet["menu_id"] = menuID }
        return packet
    }

    static func editbox(text: String, inputID: String? = nil) -> [String: Any] {
        var packet: [String: Any] = [
            "type": "editbox",
            "text": text,
        ]
        if let inputID { packet["input_id"] = inputID }
        return packet
    }

    static func chat(message: String, convo: String = "local", language: String = "English") -> [String: Any] {
        [
            "type": "chat",
            "message": message,
            "convo": convo,
            "language": language,
        ]
    }

    static func ping() -> [String: Any] {
        ["type": "ping"]
    }

    static func listOnline() -> [String: Any] {
        ["type": "list_online"]
    }

    static func listOnlineWithGames() -> [String: Any] {
        ["type": "list_online_with_games"]
    }

    static func clientOptions(options: [String: Any]) -> [String: Any] {
        [
            "type": "client_options",
            "options": options,
        ]
    }

    static func documentEditorResponse(
        dialogID: String,
        action: String,
        content: String = ""
    ) -> [String: Any] {
        [
            "type": "document_editor",
            "dialog_id": dialogID,
            "action": action,
            "content": content,
        ]
    }

    static func slashCommand(command: String, args: String = "") -> [String: Any] {
        [
            "type": "slash_command",
            "command": command,
            "args": args,
        ]
    }

    static func playlistDurationResponse(
        requestID: Any,
        playlistID: String,
        durationType: String,
        duration: Int
    ) -> [String: Any] {
        [
            "type": "playlist_duration_response",
            "request_id": requestID,
            "playlist_id": playlistID,
            "duration_type": durationType,
            "duration": duration,
        ]
    }

    private static func platformString() -> String {
        #if os(iOS)
        let device = UIDevice.current
        return "iOS \(device.systemVersion) \(device.model)"
        #else
        let info = ProcessInfo.processInfo
        return "macOS \(info.operatingSystemVersionString) \(Self.machineArch())"
        #endif
    }

    private static func machineArch() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return withUnsafePointer(to: &sysinfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }
}

// MARK: - Server → Client Parsed Packets

struct MenuItem: Identifiable, Equatable {
    let id: String?
    let text: String
    let sound: String?

    init(from raw: Any) {
        if let dict = raw as? [String: Any] {
            self.text = dict["text"] as? String ?? ""
            self.id = dict["id"] as? String
            self.sound = dict["sound"] as? String
        } else {
            self.text = String(describing: raw)
            self.id = nil
            self.sound = nil
        }
    }
}

struct MenuPacketData {
    let menuID: String
    let items: [MenuItem]
    let multiletter: Bool
    let escapeBehavior: String
    let gridEnabled: Bool
    let gridWidth: Int
    let position: Int?

    init(from packet: [String: Any], previousState: MenuPacketData? = nil) {
        self.menuID = packet["menu_id"] as? String ?? ""
        let rawItems = packet["items"] as? [Any] ?? []
        self.items = rawItems.map { MenuItem(from: $0) }

        let prev = previousState?.menuID == self.menuID ? previousState : nil
        self.multiletter = packet["multiletter_enabled"] as? Bool ?? prev?.multiletter ?? true
        self.escapeBehavior = packet["escape_behavior"] as? String ?? prev?.escapeBehavior ?? "keybind"
        self.gridEnabled = packet["grid_enabled"] as? Bool ?? prev?.gridEnabled ?? false
        self.gridWidth = packet["grid_width"] as? Int ?? prev?.gridWidth ?? 1

        if let pos = packet["position"] as? Int {
            self.position = pos
        } else if let selID = packet["selection_id"] as? String {
            self.position = self.items.firstIndex(where: { $0.id == selID })
        } else {
            self.position = nil
        }
    }
}
