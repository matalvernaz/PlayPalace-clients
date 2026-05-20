import Foundation

/// Resolves a server-supplied menu item to a decorative SF Symbol name
/// for low-vision recognition.
///
/// This is a **stop-gap**. The right long-term design is for the server
/// to ship a semantic role per menu item (`startGame`, `joinTable`,
/// `settings`, etc.) and the client to map roles to symbols. That work is
/// tracked as an upstream proposal — see ``MenuItemIcon/serverRoleNote``.
///
/// Until then:
///
/// - **Prefer the stable `id`** the server already sends with each menu
///   item. IDs are English action keys (`"roll"`, `"draw"`, `"settings"`)
///   that don't change with locale.
/// - Only fall back to the display text when the id is generic or
///   missing, and match conservatively (whole-word / exact, not
///   substring) so "Restart" doesn't get the "Start" icon.
/// - Decorative only: the icon must be `accessibilityHidden` at the call
///   site. Adding "play.fill Start Game" to VoiceOver would be noise.
enum MenuItemIcon {

    /// Reminder for future maintainers: don't grow this into a 200-line
    /// localized parser. Push the semantic role into the server payload
    /// instead.
    static let serverRoleNote = """
        Long-term: server should tag each menu item with a semantic role
        (e.g. {"id":"roll","role":"primaryAction",...}). Map role→symbol
        instead of inferring from id/text.
        """

    /// Returns an SF Symbol name suitable for a menu row. Always returns
    /// something (`"circle"` fallback) so layout doesn't shift between
    /// recognised and unrecognised items.
    ///
    /// - Parameters:
    ///   - id: The stable server-side identifier, if available. Lowercased.
    ///   - text: The human-readable label (already localised on the
    ///     server). Used only as a fallback signal.
    static func symbolName(id: String?, text: String) -> String {
        if let id, let mapped = symbolForID(id.lowercased()) {
            return mapped
        }
        if let mapped = symbolForText(text) {
            return mapped
        }
        return "circle"
    }

    /// Map server-side action IDs. These are stable English keys, so we
    /// match exactly. Add new entries as the server adds new actions.
    private static func symbolForID(_ id: String) -> String? {
        switch id {
        // Game actions
        case "roll", "spin": return "dice.fill"
        case "draw", "draw_card", "deal": return "rectangle.portrait.on.rectangle.portrait.fill"
        case "hit": return "plus.circle.fill"
        case "stand", "stay", "hold": return "hand.raised.fill"
        case "shoot": return "scope"
        case "play", "play_card": return "play.fill"
        case "attack": return "bolt.fill"
        case "bid": return "tag.fill"
        case "pass": return "arrow.right.circle.fill"
        case "fold": return "xmark.circle.fill"
        case "call": return "phone.fill"
        case "raise": return "arrow.up.circle.fill"
        case "check": return "checkmark.circle"

        // Navigation
        case "back", "cancel", "escape": return "chevron.backward.circle"
        case "yes", "confirm", "ok": return "checkmark.circle.fill"
        case "no": return "xmark.circle"
        case "next": return "arrow.forward"
        case "previous", "prev": return "arrow.backward"
        case "skip": return "forward.fill"

        // Common menu items
        case "start", "start_game", "new_game", "begin": return "play.fill"
        case "join", "join_table", "join_game", "sit": return "person.2.fill"
        case "leave", "leave_table", "quit": return "rectangle.portrait.and.arrow.right"
        case "settings", "options", "preferences": return "gearshape.fill"
        case "help", "tutorial", "howto": return "questionmark.circle.fill"
        case "rules": return "book.closed.fill"
        case "score", "scores", "scoreboard": return "list.number"
        case "status": return "info.circle.fill"
        case "chat", "say", "message": return "bubble.left.fill"
        case "add_bot", "bot": return "person.fill.badge.plus"
        case "remove_bot", "kick": return "person.fill.badge.minus"
        case "ready": return "checkmark.seal.fill"
        case "list", "lobby", "rooms", "tables": return "list.bullet"
        case "create", "create_table", "new", "new_table": return "plus.circle.fill"
        case "save": return "tray.and.arrow.down.fill"
        case "load": return "tray.and.arrow.up.fill"
        case "logout", "log_out", "disconnect": return "power"

        default:
            return nil
        }
    }

    /// Fallback when only display text is available. Conservative matches
    /// only — whole-word or exact-prefix, no broad substring scans. We'd
    /// rather show a neutral bullet than the wrong icon.
    ///
    /// Matches English text. Once a locale is selected the server already
    /// returns localised strings, so unrecognised non-English labels fall
    /// through to the bullet — that's intentional, the keyword path is a
    /// guess at best and locale-sensitive matching belongs at the server.
    private static func symbolForText(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let lower = trimmed.lowercased()

        // Exact matches first.
        if let exact = symbolForID(lower) { return exact }

        // Whole-first-word matches for common verb-led labels. We split on
        // whitespace and only consider the first word so "Restart" doesn't
        // hit the "start" branch and "Re-join" doesn't hit "join".
        let firstWord = lower.split(whereSeparator: { $0.isWhitespace || $0 == "-" }).first.map(String.init)
        if let firstWord, let mapped = symbolForID(firstWord) {
            return mapped
        }

        return nil
    }
}
