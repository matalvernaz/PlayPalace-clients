import AVFoundation
import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// Manages text-to-speech output and VoiceOver integration.
@MainActor
final class SpeechManager: ObservableObject {
    private let synth = AVSpeechSynthesizer()

    /// Speak text aloud. Uses VoiceOver if running, otherwise AVSpeechSynthesizer.
    func speak(_ text: String, interrupt: Bool = true) {
        #if os(macOS)
        if NSWorkspace.shared.isVoiceOverEnabled {
            // VoiceOver is active — use it exclusively
            if interrupt { synth.stopSpeaking(at: .immediate) }
            postAnnouncement(text, priority: .high)
        } else {
            // No VoiceOver — use built-in TTS
            if interrupt { synth.stopSpeaking(at: .immediate) }
            let utterance = AVSpeechUtterance(string: text)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            synth.speak(utterance)
        }
        #elseif os(iOS)
        if UIAccessibility.isVoiceOverRunning {
            // VoiceOver is active — use it exclusively
            if interrupt { synth.stopSpeaking(at: .immediate) }
            UIAccessibility.post(notification: .announcement, argument: text)
        } else {
            // No VoiceOver — use built-in TTS
            if interrupt { synth.stopSpeaking(at: .immediate) }
            let utterance = AVSpeechUtterance(string: text)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            synth.speak(utterance)
        }
        #endif
    }

    /// Stop any current speech.
    func stop() {
        synth.stopSpeaking(at: .immediate)
    }

    /// Post a VoiceOver announcement.
    #if os(macOS)
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
    #elseif os(iOS)
    func postAnnouncement(_ text: String) {
        UIAccessibility.post(notification: .announcement, argument: text)
    }
    #endif
}
