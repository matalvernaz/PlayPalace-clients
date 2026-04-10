#if os(iOS)
import SwiftUI

/// Settings screen for customizing gesture-to-action mappings.
struct GestureSettingsView: View {
    @ObservedObject var settings: GestureSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Presets") {
                    Button("Swap two-finger and three-finger roles") {
                        settings.swapFingerGroups(2, 3)
                        settings.save()
                    }
                    .accessibilityHint("Makes two-finger gestures control buffers and three-finger gestures control game actions")

                    Button("Reset to defaults") {
                        settings.resetToDefaults()
                        settings.save()
                    }
                    .accessibilityHint("Restore all gestures to their original assignments")
                }

                gestureSection("One Finger — Currently: Menu", fingerCount: 1)
                gestureSection("Two Fingers — Currently: Game Actions", fingerCount: 2)
                gestureSection("Three Fingers — Currently: Buffers", fingerCount: 3)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Gesture Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func gestureSection(_ title: String, fingerCount: Int) -> some View {
        let gestures = GestureType.allCases.filter { $0.fingerCount == fingerCount }
        return Section(title) {
            ForEach(gestures) { gesture in
                gestureRow(gesture)
            }
        }
    }

    private func gestureRow(_ gesture: GestureType) -> some View {
        let binding = Binding<GestureAction>(
            get: { settings.action(for: gesture) },
            set: { newAction in
                settings.mapping[gesture] = newAction
                settings.save()
            }
        )

        return Picker(gesture.displayName, selection: binding) {
            ForEach(GestureAction.allCases) { action in
                Text(action.displayName).tag(action)
            }
        }
        .accessibilityLabel("\(gesture.displayName): \(settings.action(for: gesture).displayName)")
        .accessibilityHint("Double-tap to change what this gesture does")
    }
}
#endif
