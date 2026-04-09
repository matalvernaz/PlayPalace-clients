import AppKit
import SwiftUI

/// An accessible list control for server-driven menus.
/// Fully supports VoiceOver and keyboard navigation.
struct AccessibleMenuList: View {
    let items: [MenuItem]
    @Binding var selection: Int?
    let onActivate: (Int) -> Void
    let onKeyEvent: (KeyEquivalent, EventModifiers) -> Bool
    let soundManager: SoundManager
    var requestFocus: Bool = false

    @FocusState private var listFocused: Bool

    var body: some View {
        List(selection: $selection) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                MenuItemRow(item: item, isSelected: selection == index)
                    .tag(index)
                    .accessibilityLabel(item.text)
                    .accessibilityAddTraits(selection == index ? [.isSelected] : [])
                    .accessibilityHint("Activate to select this option")
            }
        }
        .listStyle(.inset)
        .onChange(of: selection) { _, newValue in
            if let idx = newValue, idx >= 0, idx < items.count {
                soundManager.playMenuClick()
                // Announce to VoiceOver
                let userInfo: [NSAccessibility.NotificationUserInfoKey: Any] = [
                    NSAccessibility.NotificationUserInfoKey(rawValue: NSAccessibility.NotificationUserInfoKey.announcement.rawValue): items[idx].text,
                    NSAccessibility.NotificationUserInfoKey(rawValue: NSAccessibility.NotificationUserInfoKey.priority.rawValue): NSAccessibilityPriorityLevel.medium.rawValue,
                ]
                NSAccessibility.post(
                    element: NSApp as Any,
                    notification: .announcementRequested,
                    userInfo: userInfo
                )
            }
        }
        .onKeyPress(.return) {
            if let sel = selection { onActivate(sel) }
            return .handled
        }
        .onKeyPress(keys: [.space, .escape, .delete,
                           .upArrow, .downArrow, .leftArrow, .rightArrow,
                           .init(.init(UnicodeScalar(NSF1FunctionKey)!)),
                           .init(.init(UnicodeScalar(NSF3FunctionKey)!)),
                           .init(.init(UnicodeScalar(NSF5FunctionKey)!))]) { press in
            let equiv = keyEquivalent(for: press)
            let mods = eventModifiers(for: press)
            if onKeyEvent(equiv, mods) { return .handled }
            return .ignored
        }
        .onKeyPress(characters: .alphanumerics) { press in
            let char = press.characters.lowercased()
            if let first = char.first {
                let equiv = KeyEquivalent(first)
                let mods = eventModifiers(for: press)
                if onKeyEvent(equiv, mods) { return .handled }
            }
            return .ignored
        }
        .focused($listFocused)
        .accessibilityLabel("Game menu, \(items.count) items")
        .accessibilityElement(children: .contain)
        .onChange(of: requestFocus) { _, shouldFocus in
            if shouldFocus { listFocused = true }
        }
        .onAppear { listFocused = true }
    }
}

private func keyEquivalent(for press: KeyPress) -> KeyEquivalent {
    switch press.key {
    case .space: return .space
    case .escape: return .escape
    case .delete: return .delete
    case .upArrow: return .upArrow
    case .downArrow: return .downArrow
    case .leftArrow: return .leftArrow
    case .rightArrow: return .rightArrow
    default:
        if let first = press.characters.first {
            return KeyEquivalent(first)
        }
        return .escape
    }
}

private func eventModifiers(for press: KeyPress) -> EventModifiers {
    var mods: EventModifiers = []
    if press.modifiers.contains(.command) { mods.insert(.command) }
    if press.modifiers.contains(.option) { mods.insert(.option) }
    if press.modifiers.contains(.shift) { mods.insert(.shift) }
    if press.modifiers.contains(.control) { mods.insert(.control) }
    return mods
}

struct MenuItemRow: View {
    let item: MenuItem
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(item.text)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}
