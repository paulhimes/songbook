import BookModel
import Combine
import Foundation

/// A Container for services used throughout the app.
@MainActor class ServiceContainer: NSObject, ObservableObject {
    /// The shared audio player of the app.
    let audioPlayer = AudioPlayer()

    /// Manages the shared audio session and responds to session changes.
    let audioSessionManager: AudioSessionManager

    /// The data model of the currently loaded book.
    let bookModel = BookModel()

    /// Interfaces with the remote command system.
    let remoteController: RemoteController

    /// Initialize the ``ServiceContainer`` and perform startup steps.
    override init() {
        audioSessionManager = AudioSessionManager(player: audioPlayer)
        remoteController = RemoteController(player: audioPlayer)

        super.init()

        // Send playable item updates to the audio player.
        _ = bookModel.$index.sink { [weak self] index in
            self?.audioPlayer.playlist = Playlist(items: index?.playableItems ?? [])
        }

        UserDefaults.standard.addObserver(
            self,
            forKeyPath: .StorageKey.currentSongId,
            options: [.initial, .new],
            context: nil
        )
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: .StorageKey.currentSongId)
    }

    // MARK: Private Functions

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        print("Current Song Id (Obz) = \(UserDefaults.standard.currentSongId!)")
        guard let currentSongId = UserDefaults.standard.currentSongId,
              let pageIndexForCurrentSongId = bookModel.index?.pageIndexFor(songId: currentSongId)
        else { return }

        guard UserDefaults.standard.currentPageIndex != pageIndexForCurrentSongId else {
            print("Invalid Current Page Index Reset")
            return
        }

//        Should we prevent setting here if the value didn't change?
        UserDefaults.standard.currentPageIndex = pageIndexForCurrentSongId
    }
}
