/// A possible audio playback mode.
enum PlaybackMode: Int {
    /// Plays a single song file, then stops.
    case single = 0
    /// Plays all song files in order and repeats.
    case continuous = 1
    /// Plays a single song file on repeat.
    case repeatOne = 2
}
