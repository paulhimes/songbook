/// Uniquely identifies a ``Song`` within a ``Book``.
public struct SongId: CustomStringConvertible {
    /// The index of the ``Section`` containing this ``Song``.
    let sectionIndex: Int

    /// The index of this ``Song`` within its ``Section``.
    let songIndex: Int

    public var description: String {
        "[\(sectionIndex), \(songIndex)]"
    }
}
