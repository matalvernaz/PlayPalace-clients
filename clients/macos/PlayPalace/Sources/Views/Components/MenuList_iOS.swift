#if os(iOS)
import SwiftUI
import UIKit

/// iOS game menu list with tap-to-activate, selection highlighting, and VoiceOver support.
/// Replaces the macOS AccessibleMenuList with touch-friendly interactions.
///
/// Low-vision parity: each row gets a leading semantic icon (decorative),
/// a leading accent stripe when selected, and bold text on the selected
/// row. Stripe width and background opacity respond to Increase Contrast
/// and Differentiate Without Color. At accessibility-tier Dynamic Type
/// sizes the row flips to a vertical stack so labels can wrap without
/// truncation.
struct MenuList_iOS: View {
    let items: [MenuItem]
    @Binding var selection: Int?
    let onActivate: (Int) -> Void

    @Environment(\.lowVision) private var lv
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
                .font(.largeTitle)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
                .accessibilityHidden(true)
            Text("Waiting for server...")
                .font(.body)
                .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
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
            .onChange(of: selection) { _, newValue in
                if let idx = newValue {
                    if let animation = lv.standardAnimation {
                        withAnimation(animation) {
                            proxy.scrollTo(idx, anchor: .center)
                        }
                    } else {
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
                if let animation = lv.standardAnimation {
                    withAnimation(animation) {
                        proxy.scrollTo(sel, anchor: .center)
                    }
                } else {
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

/// A single row in the iOS menu list.
///
/// Layout flips from horizontal (icon, text) to vertical (icon above text)
/// when the user's Dynamic Type size reaches the accessibility tier, so
/// long labels have the full row width to wrap into.
private struct MenuRow_iOS: View {
    let item: MenuItem
    let isSelected: Bool

    @Environment(\.lowVision) private var lv
    @ScaledMetric(relativeTo: .body) private var stripeMinHeight: CGFloat = 24

    private var iconName: String {
        MenuItemIcon.symbolName(id: item.id, text: item.text)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Leading accent stripe — visible only when selected. Width
            // bumps under Increase Contrast. Color-independent: the row
            // also bolds the text and (under Differentiate Without Color)
            // shows a trailing checkmark.
            stripe

            // Layout flips to vertical at AX Dynamic Type sizes so the
            // text label can wrap to multiple lines without being squashed
            // against the icon.
            adaptiveContent
        }
        .padding(.vertical, lv.isAccessibilitySize ? 8 : 4)
        .listRowBackground(rowBackground)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var stripe: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.accentColor)
                .frame(width: lv.selectionStripeWidth)
                .frame(minHeight: stripeMinHeight)
                .accessibilityHidden(true)
        } else {
            Color.clear
                .frame(width: lv.selectionStripeWidth)
                .frame(minHeight: stripeMinHeight)
        }
    }

    @ViewBuilder
    private var adaptiveContent: some View {
        if lv.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 6) {
                iconView
                textRow
            }
        } else {
            HStack(spacing: 12) {
                iconView
                textRow
            }
        }
    }

    private var iconView: some View {
        Image(systemName: iconName)
            .font(.body.weight(lv.iconWeight))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .accessibilityHidden(true)
    }

    private var textRow: some View {
        HStack(spacing: 8) {
            Text(item.text)
                .font(.body)
                .fontWeight(isSelected ? lv.selectionEmphasisWeight : nil)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Differentiate-without-color cue. Hue-independent confirmation
            // that the row is selected, in case the accent stripe / tint
            // can't be perceived.
            if isSelected && lv.differentiateWithoutColor {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    private var rowBackground: some View {
        if isSelected {
            Color.accentColor.opacity(lv.selectionBackgroundOpacity)
        } else {
            Color.clear
        }
    }
}

#if DEBUG
struct MenuList_iOS_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selection: Int? = 1
        let items = [
            MenuItem(from: ["id": "start", "text": "Start Game"]),
            MenuItem(from: ["id": "join", "text": "Join Table"]),
            MenuItem(from: ["id": "settings", "text": "Settings"]),
            MenuItem(from: ["id": "help", "text": "Help"]),
        ]

        var body: some View {
            MenuList_iOS(
                items: items,
                selection: $selection,
                onActivate: { idx in print("Activated: \(idx)") }
            )
            .installLowVisionEnvironment()
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
#endif

#endif
