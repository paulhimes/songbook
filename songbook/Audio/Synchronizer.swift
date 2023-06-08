import AVFoundation
import MediaPlayer

/// Synchronizes the now playing info and the in-app progress bar with the current playback state.
class Synchronizer {

    // MARK: Private Properties

    /// Called frequently during playback to perform light synchronization operations.
    private let continuousSyncHandler: (_ estimatedCurrentTime: TimeInterval) -> Void

    /// Updates the playback progress every time the screen refreshes.
    private var displayLink: CADisplayLink?

    /// The estimated current playback time, in seconds, is used to update the progress. The time is
    /// estimated because asking the player for the real time during each screen refresh is too
    /// slow.
    private var estimatedCurrentTime: TimeInterval = 0

    /// Called periodically during playback to perform resource intensive synchronization
    /// operations. Returns the current playback time.
    private let periodicSyncHandler: () -> TimeInterval

    /// Periodically synchronizes the `estimatedCurrentTime` and now playing info with the real
    /// `currentTime` from the `player`.
    private var periodicTimer: Timer?

    // MARK: Public Functions

    /// Initialize a ``Synchronizer`` with sync handlers which will be called at appropriate
    /// frequencies during playback.
    /// - Parameters:
    ///   - continuousSyncHandler: Called frequently during playback to perform light
    ///   synchronization operations.
    ///   - periodicSyncHandler: Called periodically during playback to perform resource intensive
    ///   synchronization operations. Returns the current playback time.
    init(
        continuousSyncHandler: @escaping (_ estimatedCurrentTime: TimeInterval) -> Void,
        periodicSyncHandler: @escaping () -> TimeInterval
    ) {
        self.continuousSyncHandler = continuousSyncHandler
        self.periodicSyncHandler = periodicSyncHandler
    }

    /// Pause synchronization updates.
    func pause() {
        displayLink?.invalidate()
        displayLink = nil
        periodicTimer?.invalidate()
        periodicTimer = nil
    }

    /// Start synchronization updates.
    func start() {
        displayLink?.invalidate()
        displayLink = nil
        periodicTimer?.invalidate()
        periodicTimer = nil

        synchronize()

        // Periodically synchronize the estimated current time and now playing time with the real
        // current time.
        let periodicTimer = Timer(timeInterval: 5, repeats: true) { [weak self] timer in
            self?.periodicSync()
        }
        RunLoop.current.add(periodicTimer, forMode: .common)
        self.periodicTimer = periodicTimer

        // Update progress every time the screen refreshes.
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(continuousSync(displayLink:))
        )
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }

    /// Stop synchronization updates.
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        periodicTimer?.invalidate()
        periodicTimer = nil
        estimatedCurrentTime = 0
    }

    /// Manually perform both a periodic and continuous sync.
    func synchronize() {
        periodicSync()
        continuousSync(displayLink: displayLink)
    }

    // MARK: Private Functions

    /// Uses a ``CADisplayLink`` to report the estimatedCurrentTime every time the screen refreshes.
    /// - Parameter displayLink: The display link.
    @objc private func continuousSync(displayLink: CADisplayLink?) {
        estimatedCurrentTime += displayLink?.duration ?? 0 // The interval between display frames.
        continuousSyncHandler(estimatedCurrentTime)
    }

    /// Called by the periodic sync timer. Gets the current time and updates `estimatedCurrentTime`.
    private func periodicSync() {
        let currentTime = periodicSyncHandler()
        let syncError = estimatedCurrentTime - currentTime
        if abs(syncError) > 0.1 {
            print("Correcting Significant Sync Error: (\(syncError))")
        }
        estimatedCurrentTime = currentTime
    }
}
