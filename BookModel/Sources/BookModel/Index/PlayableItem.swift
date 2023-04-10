import Foundation

/// An item that can be played.
public struct PlayableItem {

    /// The ``URL`` of the item's audio file.
    public let audioFileURL: URL

    /// The unique identifier of this ``PlayableItem``'s ``Song``.
    public let songId: SongId

    /// The display title of the item.
    public let title: String?
}
