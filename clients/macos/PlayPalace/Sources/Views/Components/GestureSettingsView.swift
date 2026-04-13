#if os(iOS)
import SwiftUI

/// Settings screen for customizing gesture-to-action mappings + audio volumes.
///
/// Reachable from the login screen so users can tweak audio + gestures
/// before connecting (and again from inside a session via VoiceOver's
/// custom-actions rotor → "Open controls"). Volume changes are persisted
/// through ConfigManager and picked up by the SoundManager on the next
/// `set_preference` packet from the server / on next connect.
struct GestureSettingsView: View {
    @ObservedObject var settings: GestureSettings
    @Environment(\.dismiss) private var dismiss

    private let configManager = ConfigManager()
    @State private var musicVolume: Float = 0.2
    @State private var ambienceVolume: Float = 0.2

    var body: some View {
        NavigationStack {
            List {
                Section("Volume") {
                    volumeRow(
                        label: "Music",
                        value: musicVolume,
                        down: { adjustMusic(by: -0.1) },
                        up: { adjustMusic(by: 0.1) },
                    )
                    volumeRow(
                        label: "Ambience",
                        value: ambienceVolume,
                        down: { adjustAmbience(by: -0.1) },
                        up: { adjustAmbience(by: 0.1) },
                    )
                }

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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear(perform: loadVolumes)
        }
    }

    // MARK: - Volume helpers

    private func loadVolumes() {
        let prefs = configManager.loadPreferences()
        if let m = prefs["music_volume"] as? Double {
            musicVolume = Float(m)
        }
        if let a = prefs["ambience_volume"] as? Double {
            ambienceVolume = Float(a)
        }
    }

    private func adjustMusic(by delta: Float) {
        musicVolume = max(0, min(1, musicVolume + delta))
        configManager.saveVolumes(music: musicVolume, ambience: ambienceVolume)
    }

    private func adjustAmbience(by delta: Float) {
        ambienceVolume = max(0, min(1, ambienceVolume + delta))
        configManager.saveVolumes(music: musicVolume, ambience: ambienceVolume)
    }

    private func volumeRow(
        label: String,
        value: Float,
        down: @escaping () -> Void,
        up: @escaping () -> Void,
    ) -> some View {
        let pct = Int((value * 100).rounded())
        return HStack {
            Text(label)
            Spacer()
            Button("−") { down() }
                .buttonStyle(.bordered)
                .accessibilityLabel("Decrease \(label) volume")
            Text("\(pct)%")
                .frame(minWidth: 50)
                .accessibilityHidden(true)
            Button("+") { up() }
                .buttonStyle(.bordered)
                .accessibilityLabel("Increase \(label) volume")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) volume: \(pct) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: up()
            case .decrement: down()
            @unknown default: break
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
