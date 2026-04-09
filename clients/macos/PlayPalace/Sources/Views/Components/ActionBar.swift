#if os(iOS)
import SwiftUI

/// A horizontal scrollable bar of game action buttons for iOS.
/// Provides touch access to keybinds that desktop users trigger via keyboard.
struct ActionBar: View {
    let onKeybind: (String) -> Void

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
            .fill(Color(.separator))
            .frame(width: 1, height: 36)
            .padding(.horizontal, 4)
            .accessibilityHidden(true)
    }
}

/// An individual button within the ActionBar.
/// Provides a compact rounded-rect touch target with an SF Symbol icon and text label.
private struct ActionBarButton: View {
    let icon: String
    let label: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 18)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
            }
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
struct ActionBar_Previews: PreviewProvider {
    static var previews: some View {
        ActionBar { key in
            print("Keybind: \(key)")
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

#endif
