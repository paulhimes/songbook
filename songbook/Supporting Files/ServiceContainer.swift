import BookModel
import Foundation
import Observation

/// A Container for services used throughout the app.
@MainActor
@Observable
class ServiceContainer: AudioPlayerDelegate {
    
    // MARK: Public Properties

    /// The shared audio player of the app.
    let audioPlayer = AudioPlayer()

    /// Manages the shared audio session and responds to session changes.
    let audioSessionManager: AudioSessionManager

    /// The data model of the currently loaded book.
    let bookModel = BookModel()

    /// Maintains references to user defaults observers.
    var observers: [UserDefaultsObserver] = []

    /// Debounce calls to make the audio player play. Sometimes performance of the `play` function
    /// is very slow, this prevents too many unnecessary calls.
    let playDebouncer = Debouncer(seconds: 0.5)

    // MARK: Public Functions

    /// Initialize the ``ServiceContainer`` and perform startup steps.
    init() {
        audioSessionManager = AudioSessionManager(player: audioPlayer)
        audioPlayer.delegate = self
        RemoteController.setUp(player: audioPlayer)
        observers = [
            UserDefaultsObserver(key: .StorageKey.currentPageIndex) { [weak self] in
                guard let self else { return }
                print("Current page index changed!")

                guard let playableItem = bookModel.playableItemsForPageIndex[
                    UserDefaults.standard.currentPageIndex
                ]?.first,
                      UserDefaults.standard.currentPlayableItemId != playableItem.id else { return }

                if audioPlayer.isPlaying {
                    playDebouncer.run { [weak self] in
                        guard let self else { return }
                        audioPlayer.play(playableItem)
                    }
                } else {
                    UserDefaults.standard.currentPlayableItemId = playableItem.id
                }
            },
            UserDefaultsObserver(key: .StorageKey.currentPlayableItemId) { [weak self] in
                guard let self else { return }
                print("Current playable item id changed!")

                guard let currentPlayableItemId = UserDefaults.standard.currentPlayableItemId,
                      let pageIndex = bookModel.pageIndexForPlayableItemId[currentPlayableItemId],
                      UserDefaults.standard.currentPageIndex != pageIndex else { return }

                UserDefaults.standard.currentPageIndex = pageIndex
            },
            UserDefaultsObserver(key: .StorageKey.playbackMode) { [weak self] in
                guard let self else { return }
                RemoteController.setPlaybackMode(UserDefaults.standard.playbackMode)
                audioPlayer.setPlaybackMode(UserDefaults.standard.playbackMode)
            }
        ]

        // Send playable item updates to the audio player.
        refreshAudioPlayerItems()
    }

    func currentItemChanged(item: PlayableItem) {
        UserDefaults.standard.currentPlayableItemId = item.id
    }

    // MARK: Private Functions

    /// Updates the `audioPlayer`'s items when the `bookModel`'s `playableItems` change.
    private func refreshAudioPlayerItems() {
        withObservationTracking {
            let items = bookModel.playableItems
            print("Setting \(items.count) items on audio player.")
            let currentItem = items.first { $0.id == UserDefaults.standard.currentPlayableItemId }
            let playbackMode = UserDefaults.standard.playbackMode

            audioPlayer.setItems(items, currentItem: currentItem, playbackMode: playbackMode)
        } onChange: {
            Task { @MainActor in
                self.refreshAudioPlayerItems()
            }
        }
    }
}
