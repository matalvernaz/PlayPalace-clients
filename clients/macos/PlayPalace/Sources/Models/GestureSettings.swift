#if os(iOS)
import Foundation

/// All recognized gesture types.
enum GestureType: String, CaseIterable, Codable, Identifiable {
    // One finger
    case oneFingerSwipeRight = "one_finger_swipe_right"
    case oneFingerSwipeLeft = "one_finger_swipe_left"
    case oneFingerSwipeUp = "one_finger_swipe_up"
    case oneFingerSwipeDown = "one_finger_swipe_down"
    case oneFingerDoubleTap = "one_finger_double_tap"
    case oneFingerSingleTap = "one_finger_single_tap"
    case oneFingerLongPress = "one_finger_long_press"
    // Two finger
    case twoFingerScrub = "two_finger_scrub"
    case twoFingerDoubleTap = "two_finger_double_tap"
    case twoFingerSwipeUp = "two_finger_swipe_up"
    case twoFingerSwipeDown = "two_finger_swipe_down"
    // Three finger
    case threeFingerSwipeLeft = "three_finger_swipe_left"
    case threeFingerSwipeRight = "three_finger_swipe_right"
    case threeFingerSwipeUp = "three_finger_swipe_up"
    case threeFingerSwipeDown = "three_finger_swipe_down"
    case threeFingerTap = "three_finger_tap"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oneFingerSwipeRight: return "One-finger swipe right"
        case .oneFingerSwipeLeft: return "One-finger swipe left"
        case .oneFingerSwipeUp: return "One-finger swipe up"
        case .oneFingerSwipeDown: return "One-finger swipe down"
        case .oneFingerDoubleTap: return "One-finger double-tap"
        case .oneFingerSingleTap: return "One-finger single tap"
        case .oneFingerLongPress: return "One-finger long press"
        case .twoFingerScrub: return "Two-finger scrub"
        case .twoFingerDoubleTap: return "Two-finger double-tap"
        case .twoFingerSwipeUp: return "Two-finger swipe up"
        case .twoFingerSwipeDown: return "Two-finger swipe down"
        case .threeFingerSwipeLeft: return "Three-finger swipe left"
        case .threeFingerSwipeRight: return "Three-finger swipe right"
        case .threeFingerSwipeUp: return "Three-finger swipe up"
        case .threeFingerSwipeDown: return "Three-finger swipe down"
        case .threeFingerTap: return "Three-finger tap"
        }
    }

    var fingerCount: Int {
        switch self {
        case .oneFingerSwipeRight, .oneFingerSwipeLeft, .oneFingerSwipeUp,
             .oneFingerSwipeDown, .oneFingerDoubleTap, .oneFingerSingleTap,
             .oneFingerLongPress:
            return 1
        case .twoFingerScrub, .twoFingerDoubleTap, .twoFingerSwipeUp, .twoFingerSwipeDown:
            return 2
        case .threeFingerSwipeLeft, .threeFingerSwipeRight, .threeFingerSwipeUp,
             .threeFingerSwipeDown, .threeFingerTap:
            return 3
        }
    }
}

/// All possible actions a gesture can trigger.
enum GestureAction: String, CaseIterable, Codable, Identifiable {
    case nextItem = "next_item"
    case previousItem = "previous_item"
    case activateItem = "activate_item"
    case repeatItem = "repeat_item"
    case goBack = "go_back"
    case primaryAction = "primary_action"
    case checkScore = "check_score"
    case addBot = "add_bot"
    case status = "status"
    case help = "help"
    case previousBuffer = "previous_buffer"
    case nextBuffer = "next_buffer"
    case olderMessage = "older_message"
    case newerMessage = "newer_message"
    case gridUp = "grid_up"
    case gridDown = "grid_down"
    case none = "none"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .nextItem: return "Next item"
        case .previousItem: return "Previous item"
        case .activateItem: return "Activate item"
        case .repeatItem: return "Repeat current item"
        case .goBack: return "Go back"
        case .primaryAction: return "Primary action (roll, draw)"
        case .checkScore: return "Check score"
        case .addBot: return "Add bot"
        case .status: return "Detailed status"
        case .help: return "Open help menu"
        case .previousBuffer: return "Previous buffer"
        case .nextBuffer: return "Next buffer"
        case .olderMessage: return "Older message"
        case .newerMessage: return "Newer message"
        case .gridUp: return "Grid move up"
        case .gridDown: return "Grid move down"
        case .none: return "Unassigned"
        }
    }
}

/// Stores the mapping of gestures to actions. Persisted to disk.
final class GestureSettings: ObservableObject, Codable {
    @Published var mapping: [GestureType: GestureAction]

    static let defaultMapping: [GestureType: GestureAction] = [
        // One finger — menu navigation
        .oneFingerSwipeRight: .nextItem,
        .oneFingerSwipeLeft: .previousItem,
        .oneFingerSwipeUp: .gridUp,
        .oneFingerSwipeDown: .gridDown,
        .oneFingerDoubleTap: .activateItem,
        .oneFingerSingleTap: .repeatItem,
        .oneFingerLongPress: .status,
        // Two finger — game actions
        .twoFingerScrub: .goBack,
        .twoFingerDoubleTap: .primaryAction,
        .twoFingerSwipeUp: .checkScore,
        .twoFingerSwipeDown: .addBot,
        // Three finger — buffer system
        .threeFingerSwipeLeft: .previousBuffer,
        .threeFingerSwipeRight: .nextBuffer,
        .threeFingerSwipeUp: .olderMessage,
        .threeFingerSwipeDown: .newerMessage,
        .threeFingerTap: .help,
    ]

    init() {
        self.mapping = Self.defaultMapping
    }

    func resetToDefaults() {
        mapping = Self.defaultMapping
    }

    /// Swap the roles of two finger groups.
    /// E.g., swapFingerGroups(2, 3) makes two-finger gestures do buffer actions
    /// and three-finger gestures do game actions.
    func swapFingerGroups(_ a: Int, _ b: Int) {
        let gesturesA = GestureType.allCases.filter { $0.fingerCount == a }
        let gesturesB = GestureType.allCases.filter { $0.fingerCount == b }
        let actionsA = gesturesA.map { mapping[$0] ?? .none }
        let actionsB = gesturesB.map { mapping[$0] ?? .none }

        // Assign group B's actions to group A's gestures (by position)
        for (i, gesture) in gesturesA.enumerated() {
            mapping[gesture] = i < actionsB.count ? actionsB[i] : .none
        }
        for (i, gesture) in gesturesB.enumerated() {
            mapping[gesture] = i < actionsA.count ? actionsA[i] : .none
        }
    }

    /// Look up which action a gesture triggers.
    func action(for gesture: GestureType) -> GestureAction {
        mapping[gesture] ?? .none
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case mapping
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mapping = try container.decode([GestureType: GestureAction].self, forKey: .mapping)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mapping, forKey: .mapping)
    }

    // MARK: - Persistence

    private static var filePath: URL {
        #if os(macOS)
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".playpalace/gesture_settings.json")
        #else
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("PlayPalace/gesture_settings.json")
        #endif
    }

    func save() {
        do {
            let dir = Self.filePath.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(self)
            try data.write(to: Self.filePath)
        } catch {
            print("Failed to save gesture settings: \(error)")
        }
    }

    static func load() -> GestureSettings {
        guard FileManager.default.fileExists(atPath: filePath.path),
              let data = try? Data(contentsOf: filePath),
              let settings = try? JSONDecoder().decode(GestureSettings.self, from: data) else {
            return GestureSettings()
        }
        return settings
    }
}
#endif
