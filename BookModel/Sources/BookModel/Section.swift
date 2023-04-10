/// A section in an ``Book``.
public struct Section: Codable, Equatable {
    
    /// The songs in this section.
    public let songs: [Song]
    
    /// The title of this section.
    public let title: String?
}

extension Section {
    enum CodingKeys: String, CodingKey {
        case songs
        case title = "sectionTitle"
    }
}
