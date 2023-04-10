/// A song in an ``Section``.
public struct Song: Codable, Equatable {

    /// The names of the audio files to play for this song. If no names are provided, the old
    /// automatic naming scheme is used.
    public let audioFileNames: [String]?

    /// The author of this song.
    public let author: String?
    
    /// The display number of this song.
    public let number: Int?
    
    /// The songs which are related to this song.
    public let relatedSongs: [RelatedSong]?

    /// The subtitle of this song.
    public let subtitle: String?
    
    /// The title of this song.
    public let title: String?
    
    /// The verses of this song.
    public let verses: [Verse]
    
    /// The year this song was written.
    public let year: String?
}

extension Song {
    enum CodingKeys: String, CodingKey {
        case audioFileNames = "audioFileNames"
        case author = "songAuthor"
        case number = "songNumber"
        case relatedSongs
        case subtitle = "songSubtitle"
        case title = "songTitle"
        case verses
        case year = "songYear"
    }
}
