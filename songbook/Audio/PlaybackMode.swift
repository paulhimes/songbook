import Foundation
import MediaPlayer

/// A possible audio playback mode.
enum PlaybackMode: Int, CaseIterable {
    /// Plays a single song file, then stops.
    case single = 0
    /// Plays all song files in order and repeats.
    case continuous = 1
    /// Plays a single song file on repeat.
    case repeatOne = 2
    /// Shuffles all song files and repeats.
    case shuffle = 3

    /// The UI display name for the mode.
    var displayName: String {
        switch self {
        case .single:
            return "Single"
        case .continuous:
            return "All"
        case .repeatOne:
            return "Repeat"
        case .shuffle:
            return "Shuffle"
        }
    }

    /// The SF Symbol name for the mode icon.
    var imageName: String {
        switch self {
        case .single:
            return "1.circle"
        case .continuous:
            return "repeat"
        case .repeatOne:
            return "repeat.1"
        case .shuffle:
            return "shuffle"
        }
    }

    /// The `MPRepeatType` associated with this mode.
    var repeatType: MPRepeatType {
        switch self {
        case .continuous, .shuffle:
            return .all
        case .repeatOne:
            return .one
        case .single:
            return .off
        }
    }

    /// The `MPShuffleType` associated with this mode.
    var shuffleType: MPShuffleType {
        switch self {
        case .shuffle:
            return .items
        default:
            return .off
        }
    }

    init(rawValue: Int?) {
        guard let rawValue else {
            self = .single
            return
        }
        let mode = Self.allCases.first { $0.rawValue == rawValue }
        self = mode ?? .single
    }
}
