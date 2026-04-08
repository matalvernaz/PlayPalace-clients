import AppKit
import Foundation

/// Manages text-to-speech output and VoiceOver integration.
@MainActor
final class SpeechManager: ObservableObject {
    private let synth = NSSpeechSynthesizer()

    init() {
        synth.rate = 200
    }

    /// Speak text aloud. If interrupt is true, stop any current speech first.
    func speak(_ text: String, interrupt: Bool = true) {
        if interrupt {
            synth.stopSpeaking()
        }
        synth.startSpeaking(text)

        // Also post VoiceOver announcement so VO users hear it
        // through their preferred output
        NSAccessibility.post(
            element: NSApp as Any,
            notification: .announcementRequested,
            userInfo: [
                .announcementKey: text,
                .priorityKey: NSAccessibilityPriorityLevel.high.rawValue,
            ]
        )
    }

    /// Stop any current speech.
    func stop() {
        synth.stopSpeaking()
    }

    /// Post a VoiceOver announcement without NSSpeechSynthesizer
    /// (useful when VoiceOver is handling output already).
    func postAnnouncement(_ text: String, priority: NSAccessibilityPriorityLevel = .high) {
        NSAccessibility.post(
            element: NSApp as Any,
            notification: .announcementRequested,
            userInfo: [
                .announcementKey: text,
                .priorityKey: priority.rawValue,
            ]
        )
    }
}
