import Foundation

/// An item that can be played.
public struct PlayableItem {

    /// The name of the album this song belongs to.
    public let albumTitle: String?

    /// The number of tracks in this song's album.
    public let albumTrackCount: Int

    /// The track number of this song.
    public let albumTrackNumber: Int

    /// The ``URL`` of the item's audio file.
    public let audioFileURL: URL

    /// The author of this song.
    public let author: String?

    /// The unique identifier of this ``PlayableItem``.
    public let id: PlayableItemId

    /// The identifier of the ``Song`` this ``PlayableItem`` belongs to.
    public let songId: SongId

    /// The display title of the item.
    public let title: String?
}
