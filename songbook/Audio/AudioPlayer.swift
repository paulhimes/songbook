import AVFoundation
import BookModel
import MediaPlayer

/// Plays song files.
class AudioPlayer: NSObject, ObservableObject {

    // MARK: Private Properties

    /// The player plays the sound files.
    private var player: AVAudioPlayer?

    /// Updates the playback progress every time the screen refreshes.
    private var displayLink: CADisplayLink?

    /// The estimated current playback time, in seconds, is used to update the progress. The time is
    /// estimated because asking the player for the real time during each screen refresh is too
    /// slow.
    private var estimatedCurrentTime: TimeInterval = 0

    /// `true` iff the player is currently playing.
    @Published var isPlaying = false

    /// The current playback progress as a percentage of total duration.
    lazy var progress = AudioPlayerProgress { [weak self] progress in
        print("Seek to \(progress)")
        guard let self else { return }
        guard let player = self.player else { return }
        let targetTime = player.duration * progress
        player.currentTime = targetTime
        self.estimatedCurrentTime = targetTime
    }

    /// Periodically synchronizes the `estimatedCurrentTime` with the real `currentTime` from the
    /// `player`.
    private var syncTimer: Timer?

    // MARK: Public Functions

    /// Begins playing the given ``PlayableItem``.
    /// - Parameter item: The item to play.
    func play(item: PlayableItem) {
        stop()

        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            policy: .longFormAudio
        )

        player = try? AVAudioPlayer(contentsOf: item.audioFileURL)
        player?.delegate = self
        isPlaying = true
        player?.play()

        // Update progress every time the screen refreshes.
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateProgress(displayLink:))
        )
        displayLink?.add(to: RunLoop.current, forMode: .common)

        // Periodically synchronize the estimated current time with the real current time.
        let syncTimer = Timer(timeInterval: 10, repeats: true) { [weak self] timer in
            guard let self else { return }
            if let realTime = self.player?.currentTime {
                print("Correcting Sync Error: (\(self.estimatedCurrentTime - realTime))")
                self.estimatedCurrentTime = realTime
            }
        }
        RunLoop.current.add(syncTimer, forMode: .common)
        self.syncTimer = syncTimer
    }

    /// Stops playing.
    func stop() {
        player?.pause() // Pause before stopping to avoid an audible "pop" sound.
        player?.stop()
        displayLink?.invalidate()
        displayLink = nil
        syncTimer?.invalidate()
        syncTimer = nil
        player = nil
        progress.progress = 0
        estimatedCurrentTime = 0
        isPlaying = false
    }

    // MARK: Private Functions

    /// Uses a ``CADisplayLink`` to update the playback percentage every time the screen refreshes.
    /// - Parameter displayLink: The display link.
    @objc private func updateProgress(displayLink: CADisplayLink) {
        let duration = player?.duration ?? 0
        guard duration > 0 else {
            progress.progress = 0
            return
        }
        estimatedCurrentTime += displayLink.duration // The interval between display frames.
        progress.progress = (estimatedCurrentTime / duration).limited(0...1)
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stop()
    }
}
