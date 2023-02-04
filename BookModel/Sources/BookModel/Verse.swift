/// A verse in an `Song`.
public struct Verse: Codable, Equatable {
    
    /// The index within this verse's `Song` of the verse which represents a chorus to sing after
    /// this verse.
    public let chorusIndex: Int?
    
    /// `true` iff this verse is a chorus.
    public var isChorus: Bool {
        isChorusInt ?? 0 > 0
    }
    
    /// The backing integer for the `isChorus` boolean property.
    public let isChorusInt: Int?
    
    /// The display number for the verse.
    public let number: Int?
    
    /// A portion of text to repeat at the end of the verse.
    public let repeatText: String?
    
    /// The text of the verse.
    public let text: String?
    
    /// The title of the verse.
    public let title: String?
}

extension Verse {
    enum CodingKeys: String, CodingKey {
        case chorusIndex = "verseChorusIndex"
        case isChorusInt = "verseIsChorus"
        case number = "verseNumber"
        case repeatText = "verseRepeatText"
        case text = "verseText"
        case title = "verseTitle"
    }
}
