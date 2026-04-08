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
        // Try to find sounds directory relative to the desktop client
        let desktopSounds = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Audio/
            .deletingLastPathComponent()  // Sources/
            .deletingLastPathComponent()  // PlayPalace/
            .deletingLastPathComponent()  // macos/
            .deletingLastPathComponent()  // clients/
            .appendingPathComponent("desktop")
            .appendingPathComponent("sounds")

        if FileManager.default.fileExists(atPath: desktopSounds.path) {
            soundsDirectory = desktopSounds
        } else {
            // Fallback: sounds folder next to the executable
            soundsDirectory = Bundle.main.resourceURL?
                .appendingPathComponent("sounds") ?? desktopSounds
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
        // Try the exact name first, then common audio extensions
        let candidates = [name, name.replacingOccurrences(of: ".ogg", with: ".wav"),
                          name.replacingOccurrences(of: ".ogg", with: ".mp3")]
        for candidate in candidates {
            let url = soundsDirectory.appendingPathComponent(candidate)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
            // Check subdirectories (games have sounds in subdirs)
            let enumerator = FileManager.default.enumerator(
                at: soundsDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            while let fileURL = enumerator?.nextObject() as? URL {
                if fileURL.lastPathComponent == candidate {
                    return fileURL
                }
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

        if audioType == "music" {
            soundManager?.playMusic(track, looping: false, fadeOutOld: false)
        } else {
            soundManager?.play(track)
        }
    }
}
