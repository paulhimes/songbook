import Foundation
import RegexBuilder

/// Uniquely identifies a ``PlayableItem`` within a ``Book``.
public struct PlayableItemId: CustomStringConvertible,
                              LosslessStringConvertible,
                              Equatable,
                              Hashable {
    /// The index of the ``Section`` containing this ``PlayableItem``.
    let sectionIndex: Int

    /// The index of the ``Song`` containing this ``PlayableItem``.
    let songIndex: Int

    /// The index of this ``PlayableItem`` within its ``Song``.
    let playableItemIndex: Int

    public var description: String {
        "[\(sectionIndex),\(songIndex),\(playableItemIndex)]"
    }

    /// Initialize a ``PlayableItemId`` with a section index, song index, and playable item index.
    /// - Parameters:
    ///   - sectionIndex: The index of this item‘s song‘s section.
    ///   - songIndex: The index of this item‘s song.
    ///   - playableItemIndex: The index of this item.
    public init(sectionIndex: Int, songIndex: Int, playableItemIndex: Int) {
        self.sectionIndex = sectionIndex
        self.songIndex = songIndex
        self.playableItemIndex = playableItemIndex
    }

    public init?(_ description: String) {
        let regex = Regex {
            "["
            Capture {
                OneOrMore(.digit)
            } transform: { Int($0)! }
            ","
            Capture {
                OneOrMore(.digit)
            } transform: { Int($0)! }
            ","
            Capture {
                OneOrMore(.digit)
            } transform: { Int($0)! }
            "]"
        }
        guard let match = description.wholeMatch(of: regex) else { return nil }
        sectionIndex = match.1
        songIndex = match.2
        playableItemIndex = match.3
    }
}
