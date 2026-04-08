import SwiftUI

/// An accessible list control for server-driven menus.
/// Fully supports VoiceOver and keyboard navigation.
struct AccessibleMenuList: View {
    let items: [MenuItem]
    @Binding var selection: Int?
    let onActivate: (Int) -> Void
    let onKeyEvent: (KeyEquivalent, EventModifiers) -> Bool
    let soundManager: SoundManager

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
                NSAccessibility.post(
                    element: NSApp as Any,
                    notification: .announcementRequested,
                    userInfo: [
                        .announcementKey: items[idx].text,
                        .priorityKey: NSAccessibilityPriorityLevel.medium.rawValue,
                    ]
                )
            }
        }
        .onKeyPress(.return) {
            if let sel = selection { onActivate(sel) }
            return .handled
        }
        .onKeyPress(.space) {
            if onKeyEvent(.space, []) { return .handled }
            return .ignored
        }
        .onKeyPress(.escape) {
            if onKeyEvent(.escape, []) { return .handled }
            return .ignored
        }
        .accessibilityLabel("Game menu, \(items.count) items")
        .accessibilityElement(children: .contain)
    }
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
