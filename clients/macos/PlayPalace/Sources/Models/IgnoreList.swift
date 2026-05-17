import Foundation

/// Client-side ignore list. Source of truth lives on the server when one
/// supports it (PlayPalace ≥ 11.x sends an `ignored_list` packet on
/// authorize_success), but we keep a local mirror so:
///
/// 1. Filtering still works when offline / during reconnect.
/// 2. The feature still works against vanilla XGDevGroup servers that
///    haven't picked up the protocol additions yet.
///
/// Comparison is case-insensitive — usernames are stored lowercased and
/// callers feed in any case.
@MainActor
final class IgnoreList: ObservableObject {
    /// Sorted lowercase usernames the user has chosen to ignore.
    @Published private(set) var usernames: [String] = []

    private let storageKey = "ignored_users"
    private weak var configManager: ConfigManager?

    func attach(configManager: ConfigManager) {
        self.configManager = configManager
        let stored = configManager.loadPreferences()[storageKey] as? [String] ?? []
        usernames = normalized(stored)
    }

    func contains(_ username: String) -> Bool {
        let key = normalize(username)
        return !key.isEmpty && usernames.contains(key)
    }

    /// Add a username. Returns true if it was newly added.
    @discardableResult
    func add(_ username: String) -> Bool {
        let key = normalize(username)
        guard !key.isEmpty, !usernames.contains(key) else { return false }
        usernames = (usernames + [key]).sorted()
        persist()
        return true
    }

    /// Remove a username. Returns true if it was present.
    @discardableResult
    func remove(_ username: String) -> Bool {
        let key = normalize(username)
        guard usernames.contains(key) else { return false }
        usernames.removeAll { $0 == key }
        persist()
        return true
    }

    /// Replace the entire list (used when the server pushes its
    /// authoritative copy on auth or after a sync). Persists the new list
    /// so future launches don't briefly show ignored users before the
    /// server reply lands.
    func replaceAll(_ names: [String]) {
        usernames = normalized(names)
        persist()
    }

    private func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespaces).lowercased()
    }

    private func normalized(_ names: [String]) -> [String] {
        Array(Set(names.map(normalize)).filter { !$0.isEmpty }).sorted()
    }

    private func persist() {
        configManager?.saveIgnoredUsers(usernames)
    }
}
