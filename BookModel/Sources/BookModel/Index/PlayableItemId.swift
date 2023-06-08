/// Uniquely identifies a ``PlayableItem`` within a ``Book``.
public struct PlayableItemId: CustomStringConvertible, Equatable {
    /// The index of the ``Section`` containing this ``PlayableItem``.
    let sectionIndex: Int

    /// The index of the ``Song`` containing this ``PlayableItem``.
    let songIndex: Int

    /// The index of this ``PlayableItem`` within its ``Song``.
    let playableItemIndex: Int

    public var description: String {
        "[\(sectionIndex),\(songIndex),\(playableItemIndex)]"
    }
}
