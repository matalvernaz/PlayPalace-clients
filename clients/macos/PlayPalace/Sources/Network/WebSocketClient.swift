import Foundation

/// Manages WebSocket connection to the PlayPalace server.
@MainActor
final class WebSocketClient: ObservableObject {
    /// Bounds `waitsForConnectivity` so a transient network delay fails fast
    /// and retryably instead of parking the socket (the default cap is 7 days).
    private static let connectivityTimeoutSeconds: TimeInterval = 12

    @Published private(set) var isConnected = false

    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession?
    private var shouldStop = false

    var sessionToken: String?
    var sessionExpiresAt: Int?
    var refreshToken: String?
    var refreshExpiresAt: Int?

    private weak var delegate: WebSocketDelegate?

    init(delegate: WebSocketDelegate) {
        self.delegate = delegate
    }

    // MARK: - Connection

    func connect(
        url: String,
        username: String,
        password: String,
        refreshToken: String? = nil,
        refreshExpiresAt: Int? = nil
    ) {
        disconnect()
        shouldStop = false

        self.refreshToken = refreshToken
        self.refreshExpiresAt = refreshExpiresAt

        guard let serverURL = URL(string: url) else {
            delegate?.onConnectionError("Invalid server URL")
            return
        }

        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForConnectivity = Self.connectivityTimeoutSeconds

        session = URLSession(configuration: config)
        webSocket = session?.webSocketTask(with: serverURL)
        webSocket?.resume()

        Task {
            await performAuth(username: username, password: password)
            await listenForMessages()
        }
    }

    func disconnect() {
        shouldStop = true
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        session?.invalidateAndCancel()
        session = nil
        isConnected = false
    }

    // MARK: - Auth Flow

    private func performAuth(username: String, password: String) async {
        if refreshValid() {
            let packet = ClientPacket.refreshSession(
                refreshToken: refreshToken!,
                username: username
            )
            await sendRaw(packet)

            // Wait for response with timeout
            do {
                let response = try await withTimeout(seconds: 10) {
                    try await self.receiveOne()
                }
                if let type = response["type"] as? String, type == "refresh_session_failure" {
                    clearTokens()
                    await sendRaw(ClientPacket.authorize(username: username, password: password))
                } else {
                    await handlePacket(response)
                }
            } catch {
                // A timeout here means the socket never came up in time — NOT
                // that the refresh token is bad. Surface a clean retryable error;
                // do not destroy tokens or fire a second auth on a half-dead
                // socket. The double-auth (refresh + authorize on one socket)
                // trips the server's single-session handoff and earns a 1000 close.
                if !shouldStop {
                    delegate?.onConnectionError("Connection timed out. Tap to retry.")
                }
            }
        } else {
            clearTokens()
            let packet: [String: Any]
            if sessionValid() {
                packet = ClientPacket.authorize(username: username, sessionToken: sessionToken)
            } else {
                packet = ClientPacket.authorize(username: username, password: password)
            }
            await sendRaw(packet)
        }
    }

    // MARK: - Send

    func send(_ packet: [String: Any]) {
        Task {
            await sendRaw(packet)
        }
    }

    private func sendRaw(_ packet: [String: Any]) async {
        guard let data = try? JSONSerialization.data(withJSONObject: packet),
              let text = String(data: data, encoding: .utf8) else { return }
        do {
            try await webSocket?.send(.string(text))
        } catch {
            if !shouldStop {
                isConnected = false
                delegate?.onConnectionLost()
            }
        }
    }

    // MARK: - Receive

    private func receiveOne() async throws -> [String: Any] {
        guard let msg = try await webSocket?.receive() else {
            throw WebSocketError.disconnected
        }
        switch msg {
        case .string(let text):
            guard let data = text.data(using: .utf8),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw WebSocketError.invalidJSON
            }
            return json
        case .data(let data):
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw WebSocketError.invalidJSON
            }
            return json
        @unknown default:
            throw WebSocketError.invalidJSON
        }
    }

    private func listenForMessages() async {
        while !shouldStop {
            do {
                let packet = try await receiveOne()
                await handlePacket(packet)
            } catch {
                if !shouldStop {
                    isConnected = false
                    delegate?.onConnectionLost()
                }
                break
            }
        }
    }

    // MARK: - Packet Handling

    private func handlePacket(_ packet: [String: Any]) async {
        guard let type = packet["type"] as? String else { return }

        switch type {
        case "authorize_success", "refresh_session_success":
            handleAuthSuccess(packet)
        case "refresh_session_failure":
            handleRefreshFailure(packet)
        default:
            delegate?.onPacketReceived(type: type, packet: packet)
        }
    }

    private func handleAuthSuccess(_ packet: [String: Any]) {
        if let token = packet["session_token"] as? String { sessionToken = token }
        if let expires = packet["session_expires_at"] as? Int { sessionExpiresAt = expires }
        if let token = packet["refresh_token"] as? String { refreshToken = token }
        if let expires = packet["refresh_expires_at"] as? Int { refreshExpiresAt = expires }
        isConnected = true
        delegate?.onPacketReceived(type: "authorize_success", packet: packet)
    }

    private func handleRefreshFailure(_ packet: [String: Any]) {
        clearTokens()
        let message = packet["message"] as? String ?? "Session expired. Please log in again."
        delegate?.onConnectionError(message)
    }

    // MARK: - Token Management

    private func sessionValid() -> Bool {
        guard let token = sessionToken, !token.isEmpty else { return false }
        guard let expires = sessionExpiresAt else { return true }
        return Date().timeIntervalSince1970 < Double(expires - 5)
    }

    private func refreshValid() -> Bool {
        guard let token = refreshToken, !token.isEmpty else { return false }
        guard let expires = refreshExpiresAt else { return true }
        return Date().timeIntervalSince1970 < Double(expires - 5)
    }

    private func clearTokens() {
        sessionToken = nil
        sessionExpiresAt = nil
        refreshToken = nil
        refreshExpiresAt = nil
    }
}

// MARK: - Delegate Protocol

@MainActor
protocol WebSocketDelegate: AnyObject {
    func onPacketReceived(type: String, packet: [String: Any])
    func onConnectionLost()
    func onConnectionError(_ message: String)
}

// MARK: - TLS Handling

// No custom URLSessionDelegate. Default handling enforces full system-trust
// validation against the device's trust store — the right behaviour for
// connecting to a publicly trusted Traefik cert. Self-signed dev servers
// should be reached over `ws://` on the local network (allow_insecure_ws
// is enabled server-side) or have their cert added to the device profile.

// MARK: - Helpers

enum WebSocketError: Error {
    case disconnected
    case invalidJSON
    case timeout
}

private func withTimeout<T: Sendable>(seconds: Double, operation: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw WebSocketError.timeout
        }
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
