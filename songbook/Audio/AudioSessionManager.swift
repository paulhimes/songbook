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
            for await interruption: AudioSessionInterruption in NotificationCenter.default.notifications(
                named: AVAudioSession.interruptionNotification
            ).map({
                guard let userInfo = $0.userInfo,
                      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return .ignore
                }

                switch type {
                case .ended:
                    guard let optionsValue =
                            userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                        return .ignore
                    }
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    return options.contains(.shouldResume) ? .resume : .ignore
                default:
                    // The interruption began or was in some unexpected state.
                    return .pause
                }
            }) {
                switch interruption {
                case .ignore:
                    break
                case .pause:
                    player.pause()
                case .resume:
                    // An interruption ended and playback should resume.
                    player.resumePlay()
                }
            }
        }

        routeChangesTask = Task {
            for await reason: AVAudioSession.RouteChangeReason in NotificationCenter.default.notifications(
                named: AVAudioSession.routeChangeNotification
            ).map({
                guard let userInfo = $0.userInfo,
                      let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                      let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                    return .unknown
                }
                return reason
            }) {
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

    // MARK: Nested Types

    /// A type of audio session interruption.
    enum AudioSessionInterruption: Sendable {
        // Perform no action.
        case ignore
        // Pause playback.
        case pause
        // Resume playback.
        case resume
    }
}

