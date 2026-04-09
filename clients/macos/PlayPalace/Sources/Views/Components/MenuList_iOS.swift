#if os(iOS)
import SwiftUI
import UIKit

/// iOS game menu list with tap-to-activate, selection highlighting, and VoiceOver support.
/// Replaces the macOS AccessibleMenuList with touch-friendly interactions.
struct MenuList_iOS: View {
    let items: [MenuItem]
    @Binding var selection: Int?
    let onActivate: (Int) -> Void

    @State private var scrollTarget: Int?

    var body: some View {
        Group {
            if items.isEmpty {
                emptyState
            } else {
                menuList
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Game menu, \(items.count) items")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "hourglass")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            Text("Waiting for server...")
                .font(.body)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Waiting for server to send menu options")
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Menu List

    private var menuList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    MenuRow_iOS(
                        item: item,
                        isSelected: selection == index
                    )
                    .id(index)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let previousSelection = selection
                        selection = index
                        announceSelectionChange(index: index, previous: previousSelection)
                        onActivate(index)
                    }
                    .accessibilityLabel(item.text)
                    .accessibilityAddTraits(selection == index ? [.isSelected] : [])
                    .accessibilityHint("Double tap to activate")
                    .accessibilityAction {
                        selection = index
                        onActivate(index)
                    }
                }
            }
            .listStyle(.plain)
            .onChange(of: items.count) { _, _ in
                scrollToSelection(proxy: proxy)
            }
            .onChange(of: selection) { oldValue, newValue in
                if let idx = newValue {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(idx, anchor: .center)
                    }
                }
            }
            .onAppear {
                scrollToSelection(proxy: proxy)
            }
        }
    }

    // MARK: - Helpers

    private func scrollToSelection(proxy: ScrollViewProxy) {
        if let sel = selection, sel >= 0, sel < items.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(sel, anchor: .center)
                }
            }
        }
    }

    private func announceSelectionChange(index: Int, previous: Int?) {
        guard index != previous, index >= 0, index < items.count else { return }
        let text = items[index].text
        UIAccessibility.post(
            notification: .announcement,
            argument: NSAttributedString(
                string: text,
                attributes: [.accessibilitySpeechQueueAnnouncement: true]
            )
        )
    }
}

/// A single row in the iOS menu list with selection indicator.
private struct MenuRow_iOS: View {
    let item: MenuItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }

            Text(item.text)
                .font(.body)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .listRowBackground(
            isSelected
                ? Color.accentColor.opacity(0.12)
                : Color.clear
        )
    }
}

#if DEBUG
struct MenuList_iOS_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selection: Int? = 1
        let items = [
            MenuItem(from: "Start Game"),
            MenuItem(from: "Join Table"),
            MenuItem(from: "Settings"),
            MenuItem(from: "Help"),
        ]

        var body: some View {
            MenuList_iOS(
                items: items,
                selection: $selection,
                onActivate: { idx in print("Activated: \(idx)") }
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
#endif

#endif
