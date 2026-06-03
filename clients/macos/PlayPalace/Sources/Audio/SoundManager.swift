import AVFoundation
import Foundation

/// Manages all audio playback for PlayPalace using AVFoundation.
@MainActor
final class SoundManager: ObservableObject {
    @Published var musicVolume: Float = 0.2
    @Published var ambienceVolume: Float = 0.2

    private var soundPlayers: [AVAudioPlayer] = []
    private var musicPlayer: AVAudioPlayer?
    private var ambienceLoopPlayer: AVAudioPlayer?
    private var ambienceIntroPlayer: AVAudioPlayer?
    private var playlists: [String: AudioPlaylist] = [:]

    private var menuClickSound = "menuclick.ogg"
    private var menuEnterSound = "menuenter.ogg"

    /// Base directory for sound files — looks next to the app bundle,
    /// then falls back to the desktop client's sounds folder.
    private let soundsDirectory: URL

    init() {
        // Look for sounds in the app bundle's Resources directory
        let bundleSounds = Bundle.main.resourceURL?
            .appendingPathComponent("sounds")

        if let bundleSounds, FileManager.default.fileExists(atPath: bundleSounds.path) {
            soundsDirectory = bundleSounds
        } else {
            // Fallback: sounds folder next to the app bundle
            let appDir = Bundle.main.bundleURL.deletingLastPathComponent()
            soundsDirectory = appDir.appendingPathComponent("sounds")
        }
    }

    // MARK: - Sound Effects

    func play(_ name: String, volume: Float = 1.0, pan: Float = 0.0, pitch: Float = 1.0) {
        guard let url = resolveSound(name) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.pan = pan
            player.enableRate = true
            player.rate = pitch
            player.prepareToPlay()
            player.play()
            // Keep a reference so it doesn't get deallocated
            soundPlayers.append(player)
            // Clean up finished players
            soundPlayers.removeAll { !$0.isPlaying }
        } catch {
            // Sound file not found or unplayable — fail silently
        }
    }

    /// Play a single playlist track and return its duration, so the playlist
    /// can schedule the next track. Returns 0 if the sound can't be loaded.
    func playPlaylistTrack(_ name: String, asMusic: Bool) -> TimeInterval {
        guard let url = resolveSound(name) else { return 0 }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            if asMusic {
                player.volume = musicVolume
                musicPlayer?.stop()
                musicPlayer = player
            } else {
                player.volume = 1.0
                soundPlayers.append(player)
                soundPlayers.removeAll { !$0.isPlaying }
            }
            player.prepareToPlay()
            player.play()
            return player.duration
        } catch {
            return 0
        }
    }

    func playMenuClick() {
        play(menuClickSound)
    }

    func playMenuEnter() {
        play(menuEnterSound)
    }

    func setMenuClickSound(_ name: String) { menuClickSound = name }
    func setMenuEnterSound(_ name: String) { menuEnterSound = name }

    // MARK: - Music

    func playMusic(_ name: String, looping: Bool = true, fadeOutOld: Bool = true) {
        if fadeOutOld, let current = musicPlayer, current.isPlaying {
            fadeOut(current, duration: 0.5)
        } else {
            musicPlayer?.stop()
        }

        guard let url = resolveSound(name) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = musicVolume
            player.numberOfLoops = looping ? -1 : 0
            player.prepareToPlay()
            player.play()
            musicPlayer = player
        } catch { }
    }

    func stopMusic(fade: Bool = true) {
        guard let player = musicPlayer else { return }
        if fade {
            fadeOut(player, duration: 1.0)
        } else {
            player.stop()
        }
        musicPlayer = nil
    }

    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0, min(1, volume))
        musicPlayer?.volume = musicVolume
    }

    // MARK: - Ambience

    func playAmbience(intro: String?, loop: String, outro: String?) {
        stopAmbience()
        if let intro, let url = resolveSound(intro) {
            do {
                ambienceIntroPlayer = try AVAudioPlayer(contentsOf: url)
                ambienceIntroPlayer?.volume = ambienceVolume
                ambienceIntroPlayer?.play()
            } catch { }
        }

        if let url = resolveSound(loop) {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = ambienceVolume
                player.numberOfLoops = -1
                player.prepareToPlay()

                // If there's an intro, delay starting the loop
                if let introPlayer = ambienceIntroPlayer {
                    let delay = introPlayer.duration - introPlayer.currentTime
                    player.play(atTime: player.deviceCurrentTime + delay)
                } else {
                    player.play()
                }
                ambienceLoopPlayer = player
            } catch { }
        }
    }

    func stopAmbience(force: Bool = true) {
        ambienceIntroPlayer?.stop()
        ambienceIntroPlayer = nil
        if force {
            ambienceLoopPlayer?.stop()
        } else if let player = ambienceLoopPlayer {
            fadeOut(player, duration: 1.0)
        }
        ambienceLoopPlayer = nil
    }

    func setAmbienceVolume(_ volume: Float) {
        ambienceVolume = max(0, min(1, volume))
        ambienceLoopPlayer?.volume = ambienceVolume
        ambienceIntroPlayer?.volume = ambienceVolume
    }

    // MARK: - Playlists

    func addPlaylist(
        id: String,
        tracks: [String],
        audioType: String = "music",
        shuffle: Bool = false,
        repeats: Int = 1,
        autoStart: Bool = true,
        autoRemove: Bool = true
    ) {
        removePlaylist(id)
        let playlist = AudioPlaylist(
            id: id, tracks: tracks, audioType: audioType,
            soundManager: self, shuffle: shuffle, repeats: repeats,
            autoStart: autoStart, autoRemove: autoRemove
        )
        playlists[id] = playlist
    }

    func startPlaylist(_ id: String) {
        playlists[id]?.start()
    }

    func removePlaylist(_ id: String) {
        playlists[id]?.stop()
        playlists.removeValue(forKey: id)
    }

    func removeAllPlaylists() {
        for (_, playlist) in playlists { playlist.stop() }
        playlists.removeAll()
    }

    func getPlaylist(_ id: String) -> AudioPlaylist? {
        playlists[id]
    }

    // MARK: - Helpers

    private func resolveSound(_ name: String) -> URL? {
        // Sound names arrive from the server (untrusted). Reject anything that
        // could resolve outside soundsDirectory via a path separator or "..".
        guard !name.isEmpty, !name.contains("/"), !name.contains("\\"),
              !name.contains("..") else {
            return nil
        }

        // Try the exact name first, then macOS-native formats.
        let candidates = [name, name.replacingOccurrences(of: ".ogg", with: ".caf"),
                          name.replacingOccurrences(of: ".ogg", with: ".wav"),
                          name.replacingOccurrences(of: ".ogg", with: ".mp3")]

        // Direct top-level hits.
        for candidate in candidates {
            let url = soundsDirectory.appendingPathComponent(candidate)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        // Otherwise a single walk of the tree (games keep sounds in subdirs),
        // matching any candidate by filename — one walk instead of one per
        // candidate, on the main actor.
        let candidateSet = Set(candidates)
        let enumerator = FileManager.default.enumerator(
            at: soundsDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            if candidateSet.contains(fileURL.lastPathComponent) {
                return fileURL
            }
        }
        return nil
    }

    private func fadeOut(_ player: AVAudioPlayer, duration: TimeInterval) {
        let steps = 20
        let interval = duration / Double(steps)
        let volumeStep = player.volume / Float(steps)
        Task {
            for _ in 0..<steps {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                player.volume -= volumeStep
                if player.volume <= 0 {
                    player.stop()
                    return
                }
            }
            player.stop()
        }
    }
}

// MARK: - Audio Playlist

@MainActor
final class AudioPlaylist {
    let id: String
    private let tracks: [String]
    private let audioType: String
    private weak var soundManager: SoundManager?
    private let repeats: Int
    private let autoRemove: Bool
    private var trackIndex = 0
    private var currentRepeat = 1
    private(set) var isActive = false
    private var advanceTask: Task<Void, Never>?

    init(
        id: String, tracks: [String], audioType: String,
        soundManager: SoundManager, shuffle: Bool, repeats: Int,
        autoStart: Bool, autoRemove: Bool
    ) {
        self.id = id
        var t = tracks
        if shuffle { t.shuffle() }
        self.tracks = t
        self.audioType = audioType
        self.soundManager = soundManager
        self.repeats = max(repeats, 0)
        self.autoRemove = autoRemove

        if autoStart && !tracks.isEmpty {
            isActive = true
            playNextTrack()
        }
    }

    func start() {
        guard !isActive else { return }
        isActive = true
        playNextTrack()
    }

    func stop() {
        isActive = false
        advanceTask?.cancel()
        advanceTask = nil
    }

    private func playNextTrack() {
        guard isActive, !tracks.isEmpty else { return }
        if trackIndex >= tracks.count {
            trackIndex = 0
            currentRepeat += 1
            if repeats != 0 && currentRepeat > repeats {
                stop()
                if autoRemove { soundManager?.removePlaylist(id) }
                return
            }
        }
        let track = tracks[trackIndex]
        trackIndex += 1

        // Play the track and schedule the next one when it finishes, so a
        // multi-track playlist actually advances instead of stalling on the
        // first track.
        let duration = soundManager?.playPlaylistTrack(track, asMusic: audioType == "music") ?? 0
        scheduleAdvance(after: duration)
    }

    private func scheduleAdvance(after duration: TimeInterval) {
        advanceTask?.cancel()
        guard duration > 0 else { return }
        advanceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled, let self, self.isActive else { return }
            self.playNextTrack()
        }
    }
}
