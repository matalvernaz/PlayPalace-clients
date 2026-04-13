import Foundation

struct ServerEntry: Codable, Identifiable {
    var id: String { serverID }
    var serverID: String
    var name: String
    var host: String
    var port: Int
    var notes: String
    var accounts: [String: AccountEntry]
    var lastAccountID: String?
    var trustedCertificate: TrustedCertificate?

    enum CodingKeys: String, CodingKey {
        case serverID = "server_id"
        case name, host, port, notes, accounts
        case lastAccountID = "last_account_id"
        case trustedCertificate = "trusted_certificate"
    }
}

struct AccountEntry: Codable, Identifiable {
    var id: String { accountID }
    var accountID: String
    var username: String
    var password: String
    var email: String
    var notes: String
    var refreshToken: String?
    var refreshExpiresAt: Int?

    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case username, password, email, notes
        case refreshToken = "refresh_token"
        case refreshExpiresAt = "refresh_expires_at"
    }
}

struct TrustedCertificate: Codable {
    var fingerprint: String
    var pem: String
    var host: String
    var commonName: String

    enum CodingKeys: String, CodingKey {
        case fingerprint, pem, host
        case commonName = "common_name"
    }
}

struct IdentitiesFile: Codable {
    var servers: [String: ServerEntry]
    var lastServerID: String?

    enum CodingKeys: String, CodingKey {
        case servers
        case lastServerID = "last_server_id"
    }
}

@MainActor
final class ConfigManager: ObservableObject {
    @Published var servers: [String: ServerEntry] = [:]
    @Published var lastServerID: String?

    private let basePath: URL

    init() {
        #if os(macOS)
        let home = FileManager.default.homeDirectoryForCurrentUser
        basePath = home.appendingPathComponent(".playpalace")
        #else
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        basePath = appSupport.appendingPathComponent("PlayPalace")
        #endif
        loadIdentities()
        seedDefaultServerIfNeeded()
    }

    var identitiesPath: URL { basePath.appendingPathComponent("identities.json") }
    var preferencesPath: URL { basePath.appendingPathComponent("preferences.json") }

    // MARK: - Load / Save

    func loadIdentities() {
        guard FileManager.default.fileExists(atPath: identitiesPath.path) else { return }
        do {
            let data = try Data(contentsOf: identitiesPath)
            let decoded = try JSONDecoder().decode(IdentitiesFile.self, from: data)
            servers = decoded.servers
            lastServerID = decoded.lastServerID
        } catch {
            print("Error loading identities: \(error)")
        }
    }

    func saveIdentities() {
        do {
            try FileManager.default.createDirectory(at: basePath, withIntermediateDirectories: true)
            let file = IdentitiesFile(servers: servers, lastServerID: lastServerID)
            let data = try JSONEncoder().encode(file)
            try data.write(to: identitiesPath)
        } catch {
            print("Error saving identities: \(error)")
        }
    }

    // MARK: - Server Management

    func addServer(name: String, host: String, port: Int, notes: String = "") -> String {
        let id = UUID().uuidString
        let server = ServerEntry(
            serverID: id, name: name, host: host, port: port,
            notes: notes, accounts: [:]
        )
        servers[id] = server
        saveIdentities()
        return id
    }

    func updateServer(id: String, name: String? = nil, host: String? = nil, port: Int? = nil, notes: String? = nil) {
        guard var server = servers[id] else { return }
        if let name { server.name = name }
        if let host { server.host = host }
        if let port { server.port = port }
        if let notes { server.notes = notes }
        servers[id] = server
        saveIdentities()
    }

    private func seedDefaultServerIfNeeded() {
        var changed = false

        // Primary server — PlayPalace at thealvernaz.space
        let primaryHost = "wss://playpalace.thealvernaz.space"
        let primaryPort = 443
        let hasPrimary = servers.values.contains { $0.host == primaryHost && $0.port == primaryPort }
        var primaryID: String?
        if !hasPrimary {
            let id = UUID().uuidString
            let server = ServerEntry(
                serverID: id, name: "PlayPalace", host: primaryHost,
                port: primaryPort, notes: "", accounts: [:]
            )
            servers[id] = server
            primaryID = id
            changed = true
        }

        // Secondary server — rmichie.com
        let secondaryHost = "wss://rmichie.com"
        let secondaryPort = 8000
        let hasSecondary = servers.values.contains { $0.host == secondaryHost && $0.port == secondaryPort }
        if !hasSecondary {
            let id = UUID().uuidString
            let server = ServerEntry(
                serverID: id, name: "rmichie", host: secondaryHost,
                port: secondaryPort, notes: "", accounts: [:]
            )
            servers[id] = server
            changed = true
        }

        // Default to primary server for new installs
        if lastServerID == nil {
            lastServerID = primaryID ?? servers.values.first(where: { $0.host == primaryHost })?.serverID
        }

        if changed { saveIdentities() }
    }

    func deleteServer(_ id: String) {
        servers.removeValue(forKey: id)
        if lastServerID == id { lastServerID = nil }
        saveIdentities()
    }

    func serverURL(for serverID: String) -> String? {
        guard let server = servers[serverID] else { return nil }
        let host = server.host
        let port = server.port
        if host.contains("://") {
            let scheme = host.components(separatedBy: "://").first?.lowercased() ?? "ws"
            let hostPart = host.components(separatedBy: "://").dropFirst().joined(separator: "://")
            return "\(scheme)://\(hostPart):\(port)"
        }
        return "ws://\(host):\(port)"
    }

    // MARK: - Account Management

    func addAccount(serverID: String, username: String, password: String, email: String = "", notes: String = "") -> String? {
        guard servers[serverID] != nil else { return nil }
        let id = UUID().uuidString
        let account = AccountEntry(
            accountID: id, username: username, password: password,
            email: email, notes: notes
        )
        servers[serverID]?.accounts[id] = account
        saveIdentities()
        return id
    }

    func updateAccount(serverID: String, accountID: String, username: String? = nil, password: String? = nil, refreshToken: String? = nil, refreshExpiresAt: Int? = nil) {
        guard var account = servers[serverID]?.accounts[accountID] else { return }
        if let username { account.username = username }
        if let password { account.password = password }
        if let refreshToken { account.refreshToken = refreshToken }
        if let refreshExpiresAt { account.refreshExpiresAt = refreshExpiresAt }
        servers[serverID]?.accounts[accountID] = account
        saveIdentities()
    }

    func deleteAccount(serverID: String, accountID: String) {
        servers[serverID]?.accounts.removeValue(forKey: accountID)
        if servers[serverID]?.lastAccountID == accountID {
            servers[serverID]?.lastAccountID = nil
        }
        saveIdentities()
    }

    func setLastUsed(serverID: String, accountID: String) {
        lastServerID = serverID
        servers[serverID]?.lastAccountID = accountID
        saveIdentities()
    }

    // MARK: - Preferences

    func loadPreferences() -> [String: Any] {
        guard FileManager.default.fileExists(atPath: preferencesPath.path),
              let data = try? Data(contentsOf: preferencesPath),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return json
    }

    func saveMutedBuffers(_ names: [String]) {
        var prefs = loadPreferences()
        prefs["muted_buffers"] = names
        do {
            try FileManager.default.createDirectory(at: basePath, withIntermediateDirectories: true)
            let data = try JSONSerialization.data(withJSONObject: prefs, options: .prettyPrinted)
            try data.write(to: preferencesPath)
        } catch {
            print("Error saving preferences: \(error)")
        }
    }
}
