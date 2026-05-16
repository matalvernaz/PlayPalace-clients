#if os(iOS)
import SwiftUI

/// A button that requires a deliberate double-tap to activate, matching the
/// activation model of the in-game `GameTouchView` so the whole app has one
/// interaction pattern: single tap = explore / no-op, double tap = activate.
///
/// Why not just use `Button`?
/// `Button` activates on a single tap when VoiceOver is off. In VoiceOver
/// mode the swipe-to-focus + double-tap pair already provides safety, but
/// self-voicing-with-VoiceOver-off (the mode the Getting Started text
/// encourages once you're in a game) loses that protection. The game view
/// solves it by binding `oneFingerDoubleTap → activateItem`; this view
/// extends the same model to standard sheet/list content where SwiftUI's
/// default `Button` would otherwise tap-through on the first touch.
///
/// VoiceOver behavior is unchanged: the view is exposed as `.isButton` and
/// supplies an `accessibilityAction`, so the standard VO swipe-to-focus +
/// double-tap path still calls the action exactly once.
struct DoubleTapButton<Label: View>: View {
    let role: ButtonRole?
    let isEnabled: Bool
    let fillRow: Bool
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    /// Custom-label initializer. Caller controls layout. Use when embedding
    /// in an HStack with other elements (e.g. icon buttons next to a label).
    init(
        role: ButtonRole? = nil,
        isEnabled: Bool = true,
        fillRow: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.isEnabled = isEnabled
        self.fillRow = fillRow
        self.action = action
        self.label = label
    }

    var body: some View {
        Group {
            if fillRow {
                HStack {
                    label()
                        .foregroundStyle(textColor)
                    Spacer()
                }
            } else {
                label()
                    .foregroundStyle(textColor)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            guard isEnabled else { return }
            action()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(role == .destructive ? "Destructive. Double-tap to activate." : "Double-tap to activate.")
        .accessibilityAction {
            guard isEnabled else { return }
            action()
        }
        .opacity(isEnabled ? 1.0 : 0.5)
    }

    private var textColor: Color {
        if !isEnabled { return .secondary }
        switch role {
        case .destructive: return .red
        case .cancel: return .secondary
        default: return .primary
        }
    }
}

extension DoubleTapButton where Label == Text {
    /// Plain-text convenience initializer. Fills the row width so the whole
    /// list row registers double-taps, matching how list rows feel when
    /// using Button views.
    /// `DoubleTapButton("Leave Table", role: .destructive) { ... }`.
    init(
        _ title: String,
        role: ButtonRole? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.role = role
        self.isEnabled = isEnabled
        self.fillRow = true
        self.action = action
        self.label = { Text(title) }
    }
}
#endif
