import Foundation
import MediaPlayer

/// Functions for interacting with the remote command system.
@MainActor enum RemoteController {

    // MARK: Public Functions

    /// Set up remote control with the given ``AudioPlayer``.
    static func setUp(player: AudioPlayer) {
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let changePlaybackPosition = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            player.seekTo(targetTime: changePlaybackPosition.positionTime)
            return .success
        }

        MPRemoteCommandCenter.shared().changeRepeatModeCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let changeRepeatMode = event as? MPChangeRepeatModeCommandEvent else {
                return .commandFailed
            }

            let playbackMode: PlaybackMode
            switch changeRepeatMode.repeatType {
            case .all:
                playbackMode = .continuous
            case .one:
                playbackMode = .repeatOne
            case .off:
                playbackMode = .single
            default:
                playbackMode = .single
            }
            UserDefaults.standard.playbackMode = playbackMode

            return .success
        }

        MPRemoteCommandCenter.shared().changeShuffleModeCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let changeShuffleMode = event as? MPChangeShuffleModeCommandEvent else {
                return .commandFailed
            }

            let playbackMode: PlaybackMode
            switch changeShuffleMode.shuffleType {
            case .items:
                playbackMode = .shuffle
            default:
                playbackMode = .continuous
            }
            UserDefaults.standard.playbackMode = playbackMode

            return .success
        }

        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            player.playNext()
            return .success
        }

        MPRemoteCommandCenter.shared().pauseCommand.addTarget() { event -> MPRemoteCommandHandlerStatus in
            if player.isPlaying {
                player.pause()
                return .success
            } else {
                return .commandFailed
            }
        }

        MPRemoteCommandCenter.shared().playCommand.addTarget() { event -> MPRemoteCommandHandlerStatus in
            player.resumePlay()
            return .success
        }

        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            player.playPrevious()
            return .success
        }

        MPRemoteCommandCenter.shared().stopCommand.addTarget() { event -> MPRemoteCommandHandlerStatus in
            player.stop()
            return .success
        }

        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget() { event -> MPRemoteCommandHandlerStatus in
            if player.isPlaying {
                player.pause()
            } else {
                player.resumePlay()
            }
            return .success
        }
    }

    /// Updates the remote command display for the given ``PlaybackMode``.
    /// - Parameter playbackMode: The current ``PlaybackMode``.
    static func setPlaybackMode(_ playbackMode: PlaybackMode) {
        let playbackMode = UserDefaults.standard.playbackMode

        MPRemoteCommandCenter.shared().changeRepeatModeCommand.currentRepeatType =
            playbackMode.repeatType

        MPRemoteCommandCenter.shared().changeShuffleModeCommand.currentShuffleType =
            playbackMode.shuffleType
    }
}
