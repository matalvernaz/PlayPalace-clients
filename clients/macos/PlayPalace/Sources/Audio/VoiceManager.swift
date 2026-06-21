import Foundation
import LiveKit

/// A joinable voice context — currently always a game table.
struct VoiceJoinInfo {
    let url: String
    let token: String
    let scope: String
    let contextID: String
}

/// Drives the LiveKit room for table voice chat.
///
/// The game server authorizes a join (mints the token); this connects to the
/// media SFU, joins muted (listen-only), and lets the user explicitly unmute to
/// talk. Ignored speakers are unsubscribed locally so the user never hears
/// them. Mirrors the behaviour of PlayAural's React Native MobileVoiceManager,
/// adapted to the native LiveKit Swift SDK. UI/transport concerns are injected
/// as closures so this stays focused on the room lifecycle.
@MainActor
final class VoiceManager: NSObject {
    enum ConnectionState { case disconnected, connecting, connected }

    private(set) var state: ConnectionState = .disconnected
    private(set) var microphoneEnabled = false

    private var room: Room?
    private var micBusy = false
    // Generation guard: a stale async callback must not clobber a newer join.
    private var intent = 0

    private let playEarcon: (String) -> Void
    private let announce: (String) -> Void
    private let isIgnored: (String) -> Bool

    /// Called when a join completes, so the owner can report presence upstream.
    var onConnected: ((_ scope: String, _ contextID: String) -> Void)?
    /// Called when the room drops unexpectedly (not a user-initiated leave).
    var onConnectionLost: (() -> Void)?

    init(
        playEarcon: @escaping (String) -> Void,
        announce: @escaping (String) -> Void,
        isIgnored: @escaping (String) -> Bool
    ) {
        self.playEarcon = playEarcon
        self.announce = announce
        self.isIgnored = isIgnored
        super.init()
    }

    // MARK: - Public API

    func join(_ info: VoiceJoinInfo) {
        intent += 1
        let myIntent = intent
        Task { await self.joinInternal(info, myIntent) }
    }

    func leave() {
        intent += 1
        Task { await self.leaveInternal(notify: true) }
    }

    func setMicrophoneEnabled(_ enabled: Bool) {
        Task { await self.setMicrophoneInternal(enabled) }
    }

    /// Re-apply the ignore list (e.g. after the user ignores someone mid-call).
    func reapplyIgnores() { applyIgnores() }

    // MARK: - Connection lifecycle

    private func joinInternal(_ info: VoiceJoinInfo, _ myIntent: Int) async {
        await leaveInternal(notify: false)
        guard myIntent == intent else { return }
        state = .connecting

        let room = Room()
        room.add(delegate: self)
        self.room = room
        do {
            try await room.connect(url: info.url, token: info.token)
            guard myIntent == intent else {
                await leaveInternal(notify: false)
                return
            }
            try? await room.localParticipant.setMicrophone(enabled: false)  // join muted
            microphoneEnabled = false
            state = .connected
            playEarcon("voice_join.ogg")
            announce("Connected to voice. Microphone muted.")
            applyIgnores()
            onConnected?(info.scope, info.contextID)
        } catch {
            await leaveInternal(notify: false)
            guard myIntent == intent else { return }
            state = .disconnected
            announce("Could not connect to voice chat.")
        }
    }

    private func leaveInternal(notify: Bool) async {
        guard let room else {
            state = .disconnected
            return
        }
        self.room = nil
        await room.disconnect()
        microphoneEnabled = false
        state = .disconnected
        if notify {
            playEarcon("voice_leave.ogg")
            announce("Left voice chat.")
        }
    }

    private func setMicrophoneInternal(_ enabled: Bool) async {
        guard let room, state == .connected else {
            announce("You are not in voice chat.")
            return
        }
        guard !micBusy, enabled != microphoneEnabled else { return }
        micBusy = true
        defer { micBusy = false }
        do {
            try await room.localParticipant.setMicrophone(enabled: enabled)
            microphoneEnabled = enabled
            playEarcon(enabled ? "voice_mic_on.ogg" : "voice_mic_off.ogg")
            announce(enabled ? "Microphone on." : "Microphone muted.")
        } catch {
            microphoneEnabled = false
            playEarcon("voice_mic_error.ogg")
            announce("Microphone unavailable. Check your settings.")
        }
    }

    // MARK: - Ignore handling

    /// Unsubscribe ignored speakers' audio so the user never hears them; keep
    /// everyone else subscribed.
    private func applyIgnores() {
        guard let room else { return }
        for participant in room.remoteParticipants.values {
            let ignored = isIgnored(participant.name ?? "")
            for publication in participant.audioTracks {
                guard let remote = publication as? RemoteTrackPublication else { continue }
                Task { try? await remote.set(subscribed: !ignored) }
            }
        }
    }
}

extension VoiceManager: RoomDelegate {
    nonisolated func room(_ room: Room, didDisconnectWithError error: LiveKitError?) {
        Task { @MainActor in
            let wasConnected = self.state == .connected
            self.room = nil
            self.microphoneEnabled = false
            self.state = .disconnected
            if wasConnected { self.onConnectionLost?() }
        }
    }

    nonisolated func room(_ room: Room, participantDidConnect participant: RemoteParticipant) {
        Task { @MainActor in self.applyIgnores() }
    }

    nonisolated func room(
        _ room: Room,
        participant: RemoteParticipant,
        didSubscribeTrack publication: RemoteTrackPublication
    ) {
        Task { @MainActor in self.applyIgnores() }
    }
}
