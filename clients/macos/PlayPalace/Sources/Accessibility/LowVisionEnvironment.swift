import SwiftUI

/// Aggregates the iOS accessibility environment values that affect visual
/// presentation, plus a few computed properties that translate them into
/// concrete UI knobs (stripe widths, focus-ring widths, surface opacities).
///
/// Read this with `@Environment(\.lowVision)` inside any view. The values
/// reflect the user's current Settings → Accessibility choices and update
/// automatically when those change.
///
/// Why this exists: low-vision parity needs the same set of decisions made
/// consistently across views. Without a single source of truth, two views
/// can end up applying different stripe widths or contrast bumps for the
/// same setting, and the UI gets visually incoherent.
struct LowVisionConfig {
    var reduceMotion: Bool
    var reduceTransparency: Bool
    var differentiateWithoutColor: Bool
    var showButtonShapes: Bool
    var increasedContrast: Bool
    var boldText: Bool
    var dynamicTypeSize: DynamicTypeSize

    static let `default` = LowVisionConfig(
        reduceMotion: false,
        reduceTransparency: false,
        differentiateWithoutColor: false,
        showButtonShapes: false,
        increasedContrast: false,
        boldText: false,
        dynamicTypeSize: .large
    )

    /// True when the user has chosen one of the five accessibility-tier
    /// Dynamic Type sizes. At these sizes, horizontal layouts often have to
    /// flip to vertical and paddings should shrink (text needs the edges).
    var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }

    // MARK: - Selection / focus indicators

    /// Width of the leading accent stripe on a selected row. Wider when
    /// the user has asked for stronger contrast.
    var selectionStripeWidth: CGFloat { increasedContrast ? 6 : 4 }

    /// Outline width for the keyboard / programmatic focus ring. Bumped
    /// under Bold Text or Increase Contrast — both indicate the user wants
    /// stronger visual edges everywhere.
    var focusRingWidth: CGFloat {
        if increasedContrast { return 4 }
        if boldText { return 3 }
        return 2
    }

    /// Opacity for the tint background behind a selected row. Higher
    /// under Increase Contrast / Differentiate Without Color so the
    /// selection reads at a glance, not as a faint wash.
    var selectionBackgroundOpacity: Double {
        increasedContrast ? 0.28 : (differentiateWithoutColor ? 0.22 : 0.14)
    }

    // MARK: - Surface opacities

    /// Opacity for overlay surfaces (floating buttons, HUDs) over arbitrary
    /// scene content. Pegged near-opaque whenever the user has asked for
    /// stronger contrast or for Reduce Transparency.
    ///
    /// Use this with a solid `Color(.systemBackground)` fill — not with
    /// `.regularMaterial`, which never reaches full opacity even under
    /// Reduce Transparency.
    var overlaySurfaceOpacity: Double {
        if reduceTransparency || increasedContrast { return 0.97 }
        return 0.9
    }

    /// Whether overlay surfaces should draw a hairline border. We always
    /// draw one — even without Increase Contrast, an overlay over an
    /// unpredictable game scene needs a visible edge.
    var overlayBorderOpacity: Double {
        if increasedContrast { return 0.8 }
        if differentiateWithoutColor { return 0.5 }
        return 0.25
    }

    // MARK: - Motion

    /// Animation duration to use, or zero when Reduce Motion is on. Pair
    /// with `Animation.easeInOut(duration:)` or pass to `withAnimation`.
    var standardAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.2)
    }

    /// Use this in `withAnimation { ... }` blocks instead of a literal.
    /// Falls through to an instant update under Reduce Motion.
    func animate<R>(_ body: () -> R) -> R {
        if reduceMotion {
            return body()
        } else {
            return withAnimation(.easeInOut(duration: 0.2), body)
        }
    }

    // MARK: - Text emphasis

    /// Font weight to use for "this is the selected one" cues. Bold Text
    /// already makes everything heavier, so we lean a little harder on the
    /// selected row to keep its visual rank above the rest.
    var selectionEmphasisWeight: Font.Weight {
        boldText ? .heavy : .semibold
    }

    /// Symbol weight for SF Symbols that should stay legible at small
    /// sizes. Always at least `.semibold` for low-vision parity, harder
    /// under Bold Text / Increase Contrast.
    var iconWeight: Font.Weight {
        if boldText || increasedContrast { return .bold }
        return .semibold
    }
}

private struct LowVisionConfigKey: EnvironmentKey {
    static let defaultValue: LowVisionConfig = .default
}

extension EnvironmentValues {
    var lowVision: LowVisionConfig {
        get { self[LowVisionConfigKey.self] }
        set { self[LowVisionConfigKey.self] = newValue }
    }
}

/// View modifier that reads the individual accessibility environment values
/// and exposes them as a single `LowVisionConfig` in `\.lowVision`. Apply
/// this once near the root of each scene (`ContentView`) and every
/// descendant view can read the aggregated config.
struct LowVisionEnvironmentReader: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.legibilityWeight) private var legibilityWeight
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content.environment(
            \.lowVision,
            LowVisionConfig(
                reduceMotion: reduceMotion,
                reduceTransparency: reduceTransparency,
                differentiateWithoutColor: differentiateWithoutColor,
                showButtonShapes: showButtonShapes,
                increasedContrast: colorSchemeContrast == .increased,
                boldText: legibilityWeight == .bold,
                dynamicTypeSize: dynamicTypeSize
            )
        )
    }
}

extension View {
    /// Install the aggregated `LowVisionConfig` into the environment.
    /// Apply once at the root of each scene.
    func installLowVisionEnvironment() -> some View {
        modifier(LowVisionEnvironmentReader())
    }
}

// MARK: - Visual focus ring

/// Draws a visible focus ring around the content when `isFocused` is true.
/// Independent of the system Button Shapes setting — keyboard / focus
/// users always need to see where they are, regardless of whether they've
/// also asked for button shapes.
struct FocusRingModifier: ViewModifier {
    var isFocused: Bool
    var cornerRadius: CGFloat = 10
    @Environment(\.lowVision) private var lv

    func body(content: Content) -> some View {
        content.overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: lv.focusRingWidth)
                    .padding(-3)
                    .allowsHitTesting(false)
            }
        }
    }
}

/// Draws a visible button shape around the content when the user has
/// enabled Show Button Shapes. Use on custom-styled buttons that don't get
/// the system's automatic underline / outline treatment.
struct ButtonShapeBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat = 10
    @Environment(\.lowVision) private var lv

    func body(content: Content) -> some View {
        content
            .background {
                if lv.showButtonShapes {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                }
            }
            .overlay {
                if lv.showButtonShapes {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.primary.opacity(0.45), lineWidth: 1)
                }
            }
    }
}

extension View {
    /// Outline this view when `isFocused` is true. Visible regardless of
    /// Button Shapes; widens under Increase Contrast / Bold Text.
    func focusRing(isFocused: Bool, cornerRadius: CGFloat = 10) -> some View {
        modifier(FocusRingModifier(isFocused: isFocused, cornerRadius: cornerRadius))
    }

    /// Add a system-Button-Shapes-aware backing rectangle. No-op when the
    /// user hasn't enabled Button Shapes.
    func buttonShapeBackground(cornerRadius: CGFloat = 10) -> some View {
        modifier(ButtonShapeBackgroundModifier(cornerRadius: cornerRadius))
    }

    /// "Secondary" foreground colour that gets promoted to `.primary`
    /// under Increase Contrast. Use anywhere you would have written
    /// `.foregroundStyle(.secondary)` for soft caption / tip text — this
    /// keeps the soft look in the common case but doesn't punish users
    /// who've asked the system for stronger contrast.
    func lowVisionSecondary() -> some View {
        modifier(LowVisionSecondaryModifier())
    }
}

private struct LowVisionSecondaryModifier: ViewModifier {
    @Environment(\.lowVision) private var lv

    func body(content: Content) -> some View {
        content.foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
    }
}

// MARK: - Status banners

/// A status banner that conveys error or success state with **both** a
/// colour and a shape — never colour alone. Use in place of bare
/// `Text(...).foregroundStyle(.red)` / `.green` so users with colour
/// deficiency or Differentiate Without Color enabled still get the
/// information.
struct LowVisionStatusBanner: View {
    enum Kind {
        case error
        case success
        case info

        var symbol: String {
            switch self {
            case .error: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var tint: Color {
            switch self {
            case .error: return .red
            case .success: return .green
            case .info: return .accentColor
            }
        }

        var voiceOverPrefix: String {
            switch self {
            case .error: return "Error"
            case .success: return "Success"
            case .info: return "Notice"
            }
        }
    }

    let kind: Kind
    let text: String

    @Environment(\.lowVision) private var lv

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: kind.symbol)
                .font(.body.weight(lv.iconWeight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(kind.tint)
                .accessibilityHidden(true)
            Text(text)
                .font(.callout)
                .fontWeight(lv.boldText ? .semibold : .regular)
                .foregroundStyle(lv.increasedContrast ? Color.primary : kind.tint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(kind.voiceOverPrefix): \(text)")
    }
}
