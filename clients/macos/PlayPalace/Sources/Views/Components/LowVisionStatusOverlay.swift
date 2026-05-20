#if os(iOS)
import SwiftUI

/// Floating, non-interactive status panel that surfaces the current menu
/// state visually for low-vision players.
///
/// Why this exists: the iOS game view is otherwise a blank canvas that
/// only emits speech. A blind user gets full state through the
/// SpeechManager; a low-vision user with self-voicing at low volume, in
/// a noisy room, or simply checking the screen for confirmation needs to
/// see "what am I about to activate?" without going hunting through a
/// menu sheet.
///
/// Sits above the UIKit touch view but doesn't consume hits — every
/// gesture still falls through to ``GameTouchView``. Hidden from
/// VoiceOver because the same information is already spoken; surfacing it
/// twice would just create accessibility noise.
struct LowVisionStatusOverlay: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.lowVision) private var lv

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            statusLine
            if !viewModel.menuItems.isEmpty {
                currentItemCard
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundSurface)
        .overlay(borderLine)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Status line

    private var statusLine: some View {
        HStack(spacing: 8) {
            connectionDot
            Text(viewModel.isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .fontWeight(lv.boldText ? .bold : .semibold)
                .foregroundStyle(Color.primary)

            if !viewModel.menuItems.isEmpty,
               let sel = viewModel.menuSelection,
               sel >= 0, sel < viewModel.menuItems.count {
                Text("·").font(.caption).foregroundStyle(.secondary)
                Text("Item \(sel + 1) of \(viewModel.menuItems.count)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private var connectionDot: some View {
        // Two redundant cues — colour for users who can perceive it,
        // shape for those who can't (differentiate-without-color).
        ZStack {
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            if lv.differentiateWithoutColor || lv.increasedContrast {
                Image(systemName: viewModel.isConnected ? "checkmark" : "xmark")
                    .font(.system(size: 7, weight: .heavy))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Current item card

    private var currentItemCard: some View {
        let sel = viewModel.menuSelection ?? 0
        let safeIndex = max(0, min(sel, viewModel.menuItems.count - 1))
        let item = viewModel.menuItems[safeIndex]
        let iconName = MenuItemIcon.symbolName(id: item.id, text: item.text)

        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title2.weight(lv.iconWeight))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text("Current")
                    .font(.caption2)
                    .textCase(.uppercase)
                    .foregroundStyle(lv.increasedContrast ? Color.primary : Color.secondary)
                    .tracking(0.5)
                Text(item.text)
                    .font(.headline)
                    .fontWeight(lv.boldText ? .heavy : .semibold)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Backing surface

    private var backgroundSurface: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(.systemBackground).opacity(lv.overlaySurfaceOpacity))
    }

    private var borderLine: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(
                Color.primary.opacity(lv.overlayBorderOpacity),
                lineWidth: lv.increasedContrast ? 2 : 1
            )
    }
}
#endif
