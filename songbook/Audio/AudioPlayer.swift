import AVFoundation
import BookModel
import MediaPlayer

/// Plays song files.
class AudioPlayer: NSObject, ObservableObject {

    // MARK: Public Properties

    /// `true` iff the player is currently playing.
    @Published var isPlaying: Bool = false

    /// The ``Playlist`` of ``PlayableItem``s.
    var playlist: Playlist?

    /// The current playback progress as a percentage of total duration.
    lazy var progress = AudioPlayerProgress { [weak self] progress in
        print("Seek to \(progress)")
        guard let self else { return }
        guard let player = self.player else { return }
        let targetTime = player.duration * progress
        seek(to: targetTime)
    }

    // MARK: Private Properties

    /// The player plays the sound files.
    private var player: AVAudioPlayer?

    // Synchronizes the in-app progress bar with the current playback
    // state.
    private lazy var synchronizer = Synchronizer(
        continuousSyncHandler: { [weak self] estimatedCurrentTime in
            guard let self, let player else { return }
            let duration = player.duration
            guard duration > 0 else {
                progress.progress = 0
                return
            }
            progress.progress = (estimatedCurrentTime / duration).limited(0...1)
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
        NowPlayingManager.updateNowPlaying(
            for: playlist?.currentItem,
            with: player,
            scope: .all
        )
    }

    /// Play the current item in the playlist.
    func play() {
        isPlaying = true
        if let player {
            player.play()
            synchronizer.start()
            NowPlayingManager.updateNowPlaying(
                for: playlist?.currentItem,
                with: player,
                scope: .all
            )
        } else if let playlist {
            play(item: playlist.currentItem)
        }
    }

    /// Play the next item in the playlist.
    func playNext() {
        guard let playlist else { return }
        play(item: playlist.stepForward())
    }

    /// Play the previous item in the playlist.
    func playPrevious() {
        guard let playlist else { return }
        play(item: playlist.stepBackward())
    }

    /// Play the given item.
    /// - Parameter index: The item to play.
    func play(item: PlayableItem) {
        player?.pause() // Pause before stopping to avoid an audible "pop" sound.
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: item.audioFileURL)
        player?.delegate = self
        UserDefaults.standard.currentSongId = item.songId
        play()
    }

    /// Seek the currently playing item to the given target time.
    /// - Parameter targetTime: The time to seek the current item.
    func seek(to targetTime: TimeInterval) {
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
        NowPlayingManager.updateNowPlaying(
            for: playlist?.currentItem,
            with: player,
            scope: .all
        )
    }

    /// Stops playing.
    func stop() {
        isPlaying = false
        synchronizer.stop()
        synchronizer.synchronize()
        player?.pause() // Pause before stopping to avoid an audible "pop" sound.
        player?.stop()
        player = nil
        progress.progress = 0
        NowPlayingManager.updateNowPlaying(
            for: playlist?.currentItem,
            with: player,
            scope: .all
        )
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch UserDefaults.standard.playbackMode {
        case .continuous, .shuffle:
            guard let playlist else { return }
            play(item: playlist.stepForward())
        case .repeatOne:
            guard let playlist else { return }
            play(item: playlist.currentItem)
        case .single:
            stop()
        }
    }
}
