import AVFoundation
import BookModel
import MediaPlayer
import Observation

/// Plays song files.
@MainActor
@Observable
class AudioPlayer: NSObject {

    // MARK: Public Properties

    /// Receives delegate callbacks from ``AudioPlayer``.
    weak var delegate: AudioPlayerDelegate?

    /// `true` iff the player is currently playing.
    var isPlaying: Bool = false

    /// The current playback progress as a percentage of total duration.
    var progress: Double = 0

    // MARK: Private Properties

    /// The current ``PlaybackMode``.
    private var playbackMode: PlaybackMode = .single

    /// The player plays the sound files.
    private var player: AVAudioPlayer?

    /// The ``Playlist`` of ``PlayableItem``s.
    private var playlist: Playlist?

    // Synchronizes the in-app progress bar with the current playback state.
    @ObservationIgnored
    private lazy var synchronizer = Synchronizer(
        continuousSyncHandler: { [weak self] estimatedCurrentTime in
            guard let self, let player else { return }
            let duration = player.duration
            guard duration > 0 else {
                progress = 0
                return
            }
            progress = (estimatedCurrentTime / duration).limited(0...1)
        },
        periodicSyncHandler: { [weak self] in
            guard let self else { return 0 }
            return player?.currentTime ?? 0
        }
    )

    // MARK: Public Functions

    /// Pause playback.
    func pause() {
        isPlaying = false
        player?.pause()
        synchronizer.pause()
        synchronizer.synchronize()
        NowPlayingManager.updateNowPlaying(for: playlist?.currentItem, with: player)
    }

    /// Play the next item in the playlist.
    func playNext() {
        playlist?.stepForward()
        guard let item = playlist?.currentItem else {
            stop()
            return
        }
        play(item)
    }

    /// Play the previous item in the playlist.
    func playPrevious() {
        playlist?.stepBackward()
        guard let item = playlist?.currentItem else {
            stop()
            return
        }
        play(item)
    }

    /// Start playing at the beginning of the given item.
    /// - Parameter item: The current item.
    func play(_ item: PlayableItem?) {
        guard let item else {
            stop()
            return
        }

        synchronizer.stop()
        progress = 0
        player?.pause() // Pause before stopping to avoid an audible "pop" sound.
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: item.audioFileURL)
        player?.prepareToPlay()
        player?.delegate = self
        playlist?.currentItem = item
        delegate?.currentItemChanged(item: item)
        isPlaying = true
        player?.play()
        synchronizer.start()
        NowPlayingManager.updateNowPlaying(for: playlist?.currentItem, with: player)
    }

    /// Play the current item in the playlist.
    func resumePlay() {
        if let player {
            isPlaying = true
            player.play()
            synchronizer.start()
            NowPlayingManager.updateNowPlaying(for: playlist?.currentItem, with: player)
        } else if let playlist {
            play(playlist.currentItem)
        }
    }
    
    /// Seek the currently playing item to the given progress percentage of total duration.
    /// - Parameter progress: The progress percentage of total duration to seek the current item.
    func seekTo(progress: Double) {
        print("Seek to progress \(progress)")

        guard let player else { return }

        let targetTime = player.duration * progress
        seekTo(targetTime: targetTime)
    }

    /// Seek the currently playing item to the given target time.
    /// - Parameter targetTime: The time to seek the current item.
    func seekTo(targetTime: TimeInterval) {
        print("Seek to target time \(targetTime)")

        guard let player else { return }

        // Seeking too close to the end causes the player to start playing from the beginning.
        let targetTime = min(player.duration - 0.05, targetTime)

        if player.isPlaying {
            player.pause()
            player.currentTime = targetTime
            player.play()
        } else {
            player.currentTime = targetTime
        }
        synchronizer.synchronize()
        NowPlayingManager.updateNowPlaying(for: playlist?.currentItem, with: player)
    }

    /// Sets the playlist of currently playable items.
    /// - Parameters:
    ///   - items: The currently playable items.
    ///   - currentItem: The currently playable item.
    ///   - playbackMode: The current ``PlaybackMode``.
    func setItems(_ items: [PlayableItem], currentItem: PlayableItem?, playbackMode: PlaybackMode) {
        playlist = Playlist(items: items, currentItem: currentItem, playbackMode: playbackMode)
    }

    /// Sets the current ``PlaybackMode``.
    /// - Parameter playbackMode: The new ``PlaybackMode``
    func setPlaybackMode(_ playbackMode: PlaybackMode) {
        self.playbackMode = playbackMode
        playlist?.updatePlayOrderForMode(playbackMode)
    }

    /// Stops playing.
    func stop() {
        isPlaying = false
        synchronizer.stop()
        player?.pause() // Pause before stopping to avoid an audible "pop" sound.
        player?.stop()
        player = nil
        progress = 0
        NowPlayingManager.updateNowPlaying(for: playlist?.currentItem, with: player)
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch playbackMode {
        case .continuous, .shuffle:
            playNext()
        case .repeatOne:
            resumePlay()
        case .single:
            stop()
        }
    }
}
