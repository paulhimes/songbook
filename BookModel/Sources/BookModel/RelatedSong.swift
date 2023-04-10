/// The indices of a song which is related to another song.
public struct RelatedSong: Codable, Equatable {
    
    /// The index of the ``Section`` in the ``Book`` to which the related song belongs.
    public let sectionIndex: Int
    
    /// The index of the related ``Song`` in its ``Section``.
    public let songIndex: Int
}

extension RelatedSong {
    enum CodingKeys: String, CodingKey {
        case sectionIndex = "relatedSongSectionIndex"
        case songIndex = "relatedSongIndex"
    }
}
