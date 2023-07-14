import BookModel
import Combine
import Foundation

/// ``Playlist`` manages a collection of ``PlayableItem``s. It determines the play order and
/// provides access to the current item.
struct Playlist {

    // MARK: Public Properties

    /// The current item.
    var currentItem: PlayableItem {
        get {
            items[itemIndex]
        }
        set {
            guard let itemIndex = items.firstIndex(where: { $0.id == newValue.id }),
                  let playOrderIndex = playOrder.firstIndex(of: itemIndex) else {
                playOrderIndex = 0
                return
            }
            self.playOrderIndex = playOrderIndex
        }
    }

    // MARK: Private Properties

    /// The playable items in sequential order.
    private let items: [PlayableItem]

    /// The index in the `items` array of the current item.
    private var itemIndex: Int {
        playOrder[playOrderIndex]
    }

    /// An array of indices into the `items` array.
    private var playOrder: [Int]

    /// The index in the `playOrder` array of the current item's index.
    private var playOrderIndex: Int

    // MARK: Public Functions

    /// Initialize a ``Playlist`` with an array of ``PlayableItem``s.
    /// - Parameters:
    ///   - items: The playable items in sequential order.
    ///   - currentItem: The current playable item.
    ///   - playbackMode: The current ``PlaybackMode``.
    init?(items: [PlayableItem], currentItem: PlayableItem?, playbackMode: PlaybackMode) {
        guard !items.isEmpty,
              let currentItem,
              items.contains(where: { $0.id == currentItem.id }) else {
            return nil
        }
        self.items = items

        playOrder = items.enumerated().map({ $0.offset })
        playOrderIndex = items.firstIndex(where: { $0.id == currentItem.id }) ?? 0
        updatePlayOrderForMode(playbackMode)
    }

    /// Makes the previous item in the playlist the current item.
    mutating func stepBackward() {
        playOrderIndex = ((playOrderIndex - 1) + playOrder.count) % playOrder.count
    }

    /// Makes the next item in the playlist the current item.
    mutating func stepForward() {
        playOrderIndex = ((playOrderIndex + 1) + playOrder.count) % playOrder.count
    }

    /// Updates the `playOrder` array and `playOrderIndex` for a given ``PlaybackMode``.
    /// - Parameter playbackMode: The current ``PlaybackMode``.
    mutating func updatePlayOrderForMode(_ playbackMode: PlaybackMode) {
        let currentItem = currentItem
        switch playbackMode {
        case .shuffle:
            playOrder = items.enumerated().map({ $0.offset }).shuffled()
        default:
            playOrder = items.enumerated().map({ $0.offset })
        }
        // Reacquire the current item in the new play order.
        self.currentItem = currentItem
    }
}
