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

    /// Where each requested sound name was found, and names known to be
    /// missing. The server asks for ".ogg" names and the app ships ".caf"
    /// files, so without this every sound paid for a full walk of the sounds
    /// folder on the main thread before trying the ".caf" name.
    private var resolvedSounds: [String: URL] = [:]
    private var missingSounds: Set<String> = []
    /// Every file in the sounds folder by its bare file name, built once, for
    /// servers that send a bare name without the game folder.
    private lazy var soundsByFileName: [String: URL] = indexSoundsByFileName()

    /// What should keep playing, so it can be started again after a phone
    /// call or Siri interrupts it, or after iOS resets its audio system.
    private var currentMusic: (name: String, looping: Bool)?
    private var currentAmbience: (intro: String?, loop: String, outro: String?)?
    private var interruptionObservers: [NSObjectProtocol] = []

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
        observeAudioInterruptions()
    }

    // MARK: - Interruptions

    /// A phone call, Siri or an alarm pauses every player; iOS doesn't resume
    /// them. One-shot effects recover on their own because each is a new
    /// player, but the looping music and ambience stayed silent until the
    /// server happened to change tracks. Start them again when the
    /// interruption ends, and rebuild them if iOS resets its audio system.
    private func observeAudioInterruptions() {
        #if os(iOS)
        let center = NotificationCenter.default
        interruptionObservers.append(center.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: raw) == .ended else { return }
            Task { @MainActor [weak self] in self?.resumeLoopsAfterInterruption() }
        })
        interruptionObservers.append(center.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.rebuildLoopsAfterReset() }
        })
        #endif
    }

    private func resumeLoopsAfterInterruption() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        if let player = musicPlayer, !player.isPlaying, currentMusic != nil {
            player.play()
        }
        if let player = ambienceLoopPlayer, !player.isPlaying, currentAmbience != nil {
            player.play()
        }
    }

    private func rebuildLoopsAfterReset() {
        // Every player belongs to the old audio system; make new ones.
        soundPlayers.removeAll()
        musicPlayer = nil
        ambienceIntroPlayer = nil
        ambienceLoopPlayer = nil
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        if let music = currentMusic {
            playMusic(music.name, looping: music.looping, fadeOutOld: false)
        }
        if let ambience = currentAmbience {
            // Back in at the loop: the intro already played before the reset.
            playAmbience(intro: nil, loop: ambience.loop, outro: ambience.outro)
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
        currentMusic = looping ? (name: name, looping: true) : nil
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
        currentMusic = nil
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
        currentAmbience = (intro: intro, loop: loop, outro: outro)
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
        currentAmbience = nil
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
        if let known = resolvedSounds[name] { return known }
        if missingSounds.contains(name) { return nil }
        // The server names a sound by its path in the pack with ".ogg"; the
        // app ships the same paths converted to other formats.
        let candidates = [name, name.replacingOccurrences(of: ".ogg", with: ".caf"),
                          name.replacingOccurrences(of: ".ogg", with: ".wav"),
                          name.replacingOccurrences(of: ".ogg", with: ".mp3")]
        for candidate in candidates {
            let url = soundsDirectory.appendingPathComponent(candidate)
            if FileManager.default.fileExists(atPath: url.path) {
                resolvedSounds[name] = url
                return url
            }
        }
        // Older servers sent bare file names for sounds kept in game folders.
        for candidate in candidates {
            if let url = soundsByFileName[candidate] {
                resolvedSounds[name] = url
                return url
            }
        }
        missingSounds.insert(name)
        return nil
    }

    private func indexSoundsByFileName() -> [String: URL] {
        var index: [String: URL] = [:]
        let enumerator = FileManager.default.enumerator(
            at: soundsDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            let fileName = fileURL.lastPathComponent
            if index[fileName] == nil {
                index[fileName] = fileURL
            }
        }
        return index
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
