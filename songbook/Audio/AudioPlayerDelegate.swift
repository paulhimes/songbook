import BookModel

/// Receives delegate callbacks from ``AudioPlayer``.
@MainActor protocol AudioPlayerDelegate: AnyObject {

    /// The current `PlayableItem` has changed.
    /// - Parameter item: The current `PlayableItem`.
    func currentItemChanged(item: PlayableItem)
}
