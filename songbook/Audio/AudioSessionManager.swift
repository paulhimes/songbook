import AVFoundation

/// Manages the shared audio session and responds to session changes.
@MainActor final class AudioSessionManager {

    // MARK: Private Properties

    /// Observes interruptions.
    private let interruptionsTask: Task<Void, Never>

    /// Observes route changes.
    private let routeChangesTask: Task<Void, Never>

    // MARK: Public Functions

    /// Initialize an `AudioSessionManager` with a player.
    /// - Parameter player: The player will be asked to pause playback during an interruption or
    ///   when a playback route device becomes unavailable.
    init(player: AudioPlayer) {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            policy: .longFormAudio
        )

        interruptionsTask = Task {
            for await notification in NotificationCenter.default.notifications(
                named: AVAudioSession.interruptionNotification
            ) {
                guard let userInfo = notification.userInfo,
                      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
                }

                switch type {
                case .ended:
                    guard let optionsValue =
                            userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        // An interruption ended and playback should resume.
                        player.resumePlay()
                    }
                default:
                    // The interruption began or was in some unexpected state.
                    player.pause()
                }
            }
        }

        routeChangesTask = Task {
            for await notification in NotificationCenter.default.notifications(
                named: AVAudioSession.routeChangeNotification
            ) {
                guard let userInfo = notification.userInfo,
                      let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                      let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                    return
                }

                // Some sort of disconnect or unplug situation. Pause playback to prevent playing
                // out loud.
                if case .oldDeviceUnavailable = reason {
                    player.pause()
                }
            }
        }
    }

    deinit {
        interruptionsTask.cancel()
        routeChangesTask.cancel()
    }
}
