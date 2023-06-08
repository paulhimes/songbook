import BookModel
import Combine
import Foundation

/// ``Playlist`` manages a collection of ``PlayableItem``s. It determines the play order and
/// provides access to the current item.
class Playlist: NSObject {

    // MARK: Public Properties

    /// The current item.
    var currentItem: PlayableItem {
        items[itemIndex]
    }

    // MARK: Private Properties

    /// The playable items in sequential order.
    private let items: [PlayableItem]

    /// The index in the `items` array of the current item.
    private var itemIndex: Int {
        playOrder[playOrderIndex]
    }

    /// The current playback mode.
    private var playbackMode: PlaybackMode? {
        didSet {
            guard let playbackMode else { return }
            let savedIndex = itemIndex
            switch playbackMode {
            case .shuffle:
                playOrder = items.enumerated().map({ $0.offset }).shuffled()
            default:
                playOrder = items.enumerated().map({ $0.offset })
            }
            if let reacquiredIndex = playOrder.firstIndex(of: savedIndex) {
                playOrderIndex = reacquiredIndex
            }
        }
    }

    /// An array of indices into the `items` array.
    private var playOrder: [Int]

    /// The index in the `playOrder` array of the current item's index.
    private var playOrderIndex: Int

    // MARK: Public Functions

    /// Initialize a ``Playlist`` with an array of ``PlayableItem``s.
    /// - Parameter items: The playable items in sequential order.
    init?(items: [PlayableItem]) {
        guard !items.isEmpty else { return nil }
        self.items = items

        playOrder = items.enumerated().map({ $0.offset })

        // Try to find a playable item for the current song.
        if let currentSongId = UserDefaults.standard.currentSongId,
           let firstMatchIndex = items.firstIndex(where: { $0.songId == currentSongId }) {
            playOrderIndex = firstMatchIndex
        } else {
            // Default to the first item.
            playOrderIndex = 0
        }

        super.init()

        UserDefaults.standard.addObserver(
            self,
            forKeyPath: .StorageKey.playbackMode,
            options: [.initial, .new],
            context: nil
        )
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: .StorageKey.playbackMode)
    }

    /// Makes the previous item in the playlist the current item.
    /// - Returns: The new current item.
    func stepBackward() -> PlayableItem {
        playOrderIndex = ((playOrderIndex - 1) + playOrder.count) % playOrder.count
        return currentItem
    }

    /// Makes the next item in the playlist the current item.
    /// - Returns: The new current item.
    func stepForward() -> PlayableItem {
        playOrderIndex = ((playOrderIndex + 1) + playOrder.count) % playOrder.count
        return currentItem
    }

    // MARK: Private Functions

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        playbackMode = UserDefaults.standard.playbackMode
    }
}
