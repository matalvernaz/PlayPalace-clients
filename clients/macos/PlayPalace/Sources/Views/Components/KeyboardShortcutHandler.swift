import SwiftUI

/// Invisible view that captures global keyboard shortcuts for the main game window.
/// Maps keyboard shortcuts to match the Python client's accelerator table.
struct KeyboardShortcutHandler: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            // Alt+M: Focus menu
            .keyboardShortcut("m", modifiers: .option)
            // F6: Toggle table chat mute
            .background(shortcutButton(.toggleTableChat) {
                viewModel.toggleTableChatMute()
            })
            // Shift+F6: Toggle global chat mute
            .background(shortcutButton(.toggleGlobalChat) {
                viewModel.toggleGlobalChatMute()
            })
            // F7: Ambience down
            .background(shortcutButton(.ambienceDown) {
                viewModel.adjustAmbienceVolume(delta: -0.1)
            })
            // F8: Ambience up
            .background(shortcutButton(.ambienceUp) {
                viewModel.adjustAmbienceVolume(delta: 0.1)
            })
            // F9: Music down
            .background(shortcutButton(.musicDown) {
                viewModel.adjustMusicVolume(delta: -0.1)
            })
            // F10: Music up
            .background(shortcutButton(.musicUp) {
                viewModel.adjustMusicVolume(delta: 0.1)
            })
            // Alt+P: Ping
            .background(shortcutButton(.ping) {
                viewModel.sendPing()
            })
            // F2: List online
            .background(shortcutButton(.listOnline) {
                viewModel.requestOnlineUsers()
            })
            // Shift+F2: List online with games
            .background(shortcutButton(.listOnlineWithGames) {
                viewModel.requestOnlineUsersWithGames()
            })
            // [ : Previous buffer
            .background(shortcutButton(.prevBuffer) {
                viewModel.previousBuffer()
            })
            // ] : Next buffer
            .background(shortcutButton(.nextBuffer) {
                viewModel.nextBuffer()
            })
            // , : Older message
            .background(shortcutButton(.olderMessage) {
                viewModel.olderMessage()
            })
            // . : Newer message
            .background(shortcutButton(.newerMessage) {
                viewModel.newerMessage()
            })
            // F4: Toggle mute buffer
            .background(shortcutButton(.toggleMute) {
                viewModel.toggleBufferMute()
            })
    }

    @ViewBuilder
    private func shortcutButton(_ id: ShortcutID, action: @escaping () -> Void) -> some View {
        Button(id.rawValue, action: action)
            .keyboardShortcut(id.key, modifiers: id.modifiers)
            .hidden()
    }
}

private enum ShortcutID: String {
    case toggleTableChat = "Toggle Table Chat"
    case toggleGlobalChat = "Toggle Global Chat"
    case ambienceDown = "Ambience Down"
    case ambienceUp = "Ambience Up"
    case musicDown = "Music Down"
    case musicUp = "Music Up"
    case ping = "Ping"
    case listOnline = "List Online"
    case listOnlineWithGames = "List Online With Games"
    case prevBuffer = "Previous Buffer"
    case nextBuffer = "Next Buffer"
    case olderMessage = "Older Message"
    case newerMessage = "Newer Message"
    case toggleMute = "Toggle Mute"

    var key: KeyEquivalent {
        switch self {
        case .toggleTableChat: return KeyEquivalent(Character(UnicodeScalar(NSF6FunctionKey)!))
        case .toggleGlobalChat: return KeyEquivalent(Character(UnicodeScalar(NSF6FunctionKey)!))
        case .ambienceDown: return KeyEquivalent(Character(UnicodeScalar(NSF7FunctionKey)!))
        case .ambienceUp: return KeyEquivalent(Character(UnicodeScalar(NSF8FunctionKey)!))
        case .musicDown: return KeyEquivalent(Character(UnicodeScalar(NSF9FunctionKey)!))
        case .musicUp: return KeyEquivalent(Character(UnicodeScalar(NSF10FunctionKey)!))
        case .ping: return "p"
        case .listOnline: return KeyEquivalent(Character(UnicodeScalar(NSF2FunctionKey)!))
        case .listOnlineWithGames: return KeyEquivalent(Character(UnicodeScalar(NSF2FunctionKey)!))
        case .prevBuffer: return "["
        case .nextBuffer: return "]"
        case .olderMessage: return ","
        case .newerMessage: return "."
        case .toggleMute: return KeyEquivalent(Character(UnicodeScalar(NSF4FunctionKey)!))
        }
    }

    var modifiers: EventModifiers {
        switch self {
        case .toggleGlobalChat, .listOnlineWithGames: return .shift
        case .ping: return .option
        default: return []
        }
    }
}
