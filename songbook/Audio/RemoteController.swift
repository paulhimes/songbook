import Foundation
import MediaPlayer

class RemoteController: NSObject {

    // MARK: Public Functions

    /// Initialize a ``RemoteController``.
    init(player: AudioPlayer) {
        super.init()

        UserDefaults.standard.addObserver(
            self,
            forKeyPath: .StorageKey.playbackMode,
            options: [.initial, .new],
            context: nil
        )

        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let changePlaybackPosition = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            player.seek(to: changePlaybackPosition.positionTime)
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
            player.play()
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
                player.play()
            }
            return .success
        }
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: .StorageKey.playbackMode)
    }

    // MARK: Private Functions

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        let playbackMode = UserDefaults.standard.playbackMode

        MPRemoteCommandCenter.shared().changeRepeatModeCommand.currentRepeatType =
            playbackMode.repeatType

        MPRemoteCommandCenter.shared().changeShuffleModeCommand.currentShuffleType =
            playbackMode.shuffleType
    }
}
