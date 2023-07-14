import Foundation

/// Uniquely identifies a ``Song`` within a ``Book``.
public struct SongId: Equatable {
    /// The index of the ``Section`` containing this ``Song``.
    let sectionIndex: Int

    /// The index of this ``Song`` within its ``Section``.
    let songIndex: Int

    /// Initialize a ``SongId`` with a section index and song index.
    /// - Parameters:
    ///   - sectionIndex: The index of this song's section.
    ///   - songIndex: The index of this song.
    public init(sectionIndex: Int, songIndex: Int) {
        self.sectionIndex = sectionIndex
        self.songIndex = songIndex
    }
}
