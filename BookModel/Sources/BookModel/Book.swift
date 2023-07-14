import Foundation

/// A book on its way to or from a .songbook file.
public struct Book: Codable, Equatable {
    
    /// An email to contact with feedback about the book.
    public let contactEmail: String?
    
    /// The sections of the book.
    public let sections: [Section]
    
    /// The title of the book.
    public let title: String
    
    /// The ``URL`` to check for automatic book updates.
    public let updateURL: URL?
    
    /// The version of the book.
    public let version: Int
}

extension Book {
    enum CodingKeys: String, CodingKey {
        case contactEmail
        case sections
        case title = "bookTitle"
        case updateURL
        case version
    }
}
