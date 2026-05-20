#if os(iOS)
import SwiftUI

/// A horizontal scrollable bar of game action buttons for iOS.
/// Provides touch access to keybinds that desktop users trigger via keyboard.
///
/// Low-vision parity: icons and labels use semantic Dynamic Type sizes so
/// they scale with the user's text-size setting. Touch targets grow with
/// text size via `@ScaledMetric`. At accessibility-tier sizes the buttons
/// switch to a label-only horizontal style so the larger text isn't
/// crammed under the icon. Under Show Button Shapes the buttons get a
/// visible outline.
struct ActionBar: View {
    let onKeybind: (String) -> Void

    @Environment(\.lowVision) private var lv

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                // Navigation group
                actionGroup {
                    ActionBarButton(
                        icon: "chevron.backward",
                        label: "Back",
                        accessibilityLabel: "Go back",
                        accessibilityHint: "Send escape to the server"
                    ) { onKeybind("escape") }

                    ActionBarButton(
                        icon: "checkmark",
                        label: "Enter",
                        accessibilityLabel: "Confirm",
                        accessibilityHint: "Confirm the current selection"
                    ) { onKeybind("enter") }
                }

                groupDivider

                // Game actions group
                actionGroup {
                    ActionBarButton(
                        icon: "dice",
                        label: "Roll",
                        accessibilityLabel: "Roll",
                        accessibilityHint: "Roll the dice"
                    ) { onKeybind("r") }

                    ActionBarButton(
                        icon: "rectangle.portrait.on.rectangle.portrait",
                        label: "Draw",
                        accessibilityLabel: "Draw card",
                        accessibilityHint: "Draw a card from the deck"
                    ) { onKeybind("space") }

                    ActionBarButton(
                        icon: "list.number",
                        label: "Score",
                        accessibilityLabel: "Check score",
                        accessibilityHint: "View the current scores"
                    ) { onKeybind("s") }
                }

                groupDivider

                // Arrow keys group
                actionGroup {
                    ActionBarButton(
                        icon: "arrow.up",
                        label: "Up",
                        accessibilityLabel: "Move up",
                        accessibilityHint: "Navigate up"
                    ) { onKeybind("up") }

                    ActionBarButton(
                        icon: "arrow.down",
                        label: "Down",
                        accessibilityLabel: "Move down",
                        accessibilityHint: "Navigate down"
                    ) { onKeybind("down") }

                    ActionBarButton(
                        icon: "arrow.left",
                        label: "Left",
                        accessibilityLabel: "Move left",
                        accessibilityHint: "Navigate left"
                    ) { onKeybind("left") }

                    ActionBarButton(
                        icon: "arrow.right",
                        label: "Right",
                        accessibilityLabel: "Move right",
                        accessibilityHint: "Navigate right"
                    ) { onKeybind("right") }
                }

                groupDivider

                // Number keys group
                actionGroup {
                    ForEach(1...9, id: \.self) { number in
                        ActionBarButton(
                            icon: "\(number).circle",
                            label: "\(number)",
                            accessibilityLabel: "Number \(number)",
                            accessibilityHint: "Send number \(number) to the game"
                        ) { onKeybind("\(number)") }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Game actions")
    }

    // MARK: - Subviews

    @ViewBuilder
    private func actionGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 4) {
            content()
        }
    }

    private var groupDivider: some View {
        Rectangle()
            .fill(Color(.separator).opacity(lv.increasedContrast ? 1.0 : 0.6))
            .frame(width: lv.increasedContrast ? 2 : 1, height: 36)
            .padding(.horizontal, 4)
            .accessibilityHidden(true)
    }
}

/// An individual button within the ActionBar.
///
/// At standard Dynamic Type sizes the layout is icon-above-label inside a
/// compact rounded-rect. At accessibility-tier sizes the label sits beside
/// the icon and the button stretches to fit, because stacking a 24+ pt
/// label beneath an icon makes a button that's neither readable nor
/// thumbable.
private struct ActionBarButton: View {
    let icon: String
    let label: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let action: () -> Void

    @Environment(\.lowVision) private var lv

    // Scaled so touch targets grow with Dynamic Type — 44pt at default,
    // ~60pt at .accessibility3, ~80pt at .accessibility5. The minimum-44
    // target is the iOS HIG floor.
    @ScaledMetric(relativeTo: .body) private var compactTouchTarget: CGFloat = 56
    @ScaledMetric(relativeTo: .body) private var iconBoxHeight: CGFloat = 22

    var body: some View {
        Button(action: action) {
            content
                .frame(minWidth: 44, minHeight: 44)
                .padding(.horizontal, lv.isAccessibilitySize ? 12 : 6)
                .padding(.vertical, lv.isAccessibilitySize ? 8 : 4)
                .background(buttonBackground)
                .overlay(buttonOverlay)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
        .hoverEffect(.lift)
    }

    @ViewBuilder
    private var content: some View {
        if lv.isAccessibilitySize {
            // Horizontal layout at AX sizes: the bigger label needs the
            // width, and the bar already scrolls horizontally so making
            // each button wider is fine.
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3.weight(lv.iconWeight))
                    .accessibilityHidden(true)
                Text(label)
                    .font(.body)
                    .fontWeight(lv.boldText ? .semibold : .medium)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(minHeight: compactTouchTarget, alignment: .center)
        } else {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.body.weight(lv.iconWeight))
                    .frame(height: iconBoxHeight)
                    .accessibilityHidden(true)
                Text(label)
                    .font(.caption2)
                    .fontWeight(lv.boldText ? .semibold : .medium)
                    .lineLimit(1)
            }
            .frame(minWidth: 44, minHeight: 44)
        }
    }

    @ViewBuilder
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color(.tertiarySystemFill))
    }

    @ViewBuilder
    private var buttonOverlay: some View {
        // Always draw a hairline edge so the button is visible against the
        // grouped-background bar even before Button Shapes kicks in;
        // strengthen it under Button Shapes / Increase Contrast.
        let needsStrongEdge = lv.showButtonShapes || lv.increasedContrast
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(
                Color.primary.opacity(needsStrongEdge ? 0.55 : 0.18),
                lineWidth: needsStrongEdge ? 1.5 : 1
            )
    }
}

#if DEBUG
struct ActionBar_Previews: PreviewProvider {
    static var previews: some View {
        ActionBar { key in
            print("Keybind: \(key)")
        }
        .installLowVisionEnvironment()
        .previewLayout(.sizeThatFits)
    }
}
#endif

#endif
