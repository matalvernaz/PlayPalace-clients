import AVFoundation
import AppKit
import Foundation

/// Manages text-to-speech output and VoiceOver integration.
@MainActor
final class SpeechManager: ObservableObject {
    private let synth = AVSpeechSynthesizer()

    /// Speak text aloud. If interrupt is true, stop any current speech first.
    func speak(_ text: String, interrupt: Bool = true) {
        if interrupt {
            synth.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synth.speak(utterance)

        // Also post VoiceOver announcement so VO users hear it
        // through their preferred output
        postAnnouncement(text, priority: .high)
    }

    /// Stop any current speech.
    func stop() {
        synth.stopSpeaking(at: .immediate)
    }

    /// Post a VoiceOver announcement.
    func postAnnouncement(_ text: String, priority: NSAccessibilityPriorityLevel = .high) {
        let userInfo: [NSAccessibility.NotificationUserInfoKey: Any] = [
            NSAccessibility.NotificationUserInfoKey(rawValue: NSAccessibility.NotificationUserInfoKey.announcement.rawValue): text,
            NSAccessibility.NotificationUserInfoKey(rawValue: NSAccessibility.NotificationUserInfoKey.priority.rawValue): priority.rawValue,
        ]
        NSAccessibility.post(
            element: NSApp as Any,
            notification: .announcementRequested,
            userInfo: userInfo
        )
    }
}
