import Foundation

class AudioPlayerProgress: NSObject, ObservableObject {
    // MARK: Public Properties

    /// The current playback progress as a percentage of total duration.
    @Published var progress: Double = 0

    // MARK: Private Properties

    /// The handler to call when a seek is requested. Takes the percentage of the duration as input.
    private var seekHandler: (Double) -> Void

    // MARK: Public Functions

    /// Initializes an ``AudioPlayerProgress`` with a handler to call when a seek is requested.
    /// - Parameter seekHandler: The handler to call when a seek is requested. Takes the percentage
    /// of the duration as input.
    init(seekHandler: @escaping (Double) -> Void) {
        self.seekHandler = seekHandler
    }

    /// Seeks the player to the given progress percentage.
    /// - Parameter progress: The desired progress percentage.
    func seek(to progress: Double) {
        seekHandler(progress)
    }
}
