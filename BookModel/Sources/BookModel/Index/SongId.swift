import Foundation

/// Uniquely identifies a ``Song`` within a ``Book``.
public struct SongId: CustomStringConvertible, LosslessStringConvertible, Equatable {
    /// The index of the ``Section`` containing this ``Song``.
    let sectionIndex: Int

    /// The index of this ``Song`` within its ``Section``.
    let songIndex: Int

    public var description: String {
        "[\(sectionIndex),\(songIndex)]"
    }

    /// Initialize a ``SongId`` with a section index and song index.
    /// - Parameters:
    ///   - sectionIndex: The index of this song's section.
    ///   - songIndex: The index of this song.
    public init(sectionIndex: Int, songIndex: Int) {
        self.sectionIndex = sectionIndex
        self.songIndex = songIndex
    }

    public init?(_ description: String) {
        let trimmed = description.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        let indexes = trimmed.split(separator: ",").compactMap { Int($0) }
        guard indexes.count == 2 else { return nil }
        self.sectionIndex = indexes[0]
        self.songIndex = indexes[1]
    }
}
