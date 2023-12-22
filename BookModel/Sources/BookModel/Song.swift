/// A song in an ``Section``.
public struct Song: Codable, Equatable {

    /// The names of the audio files to play for this song. If no names are provided, the old
    /// automatic naming scheme is used.
    public let audioFileNames: [String]?

    /// The author of this song.
    public let author: String?

    /// Combines the song's `number` and `title`.
    public var combinedTitle: String {
        var title = ""
        if let number {
            title.append("\(number): ")
        }
        title.append(self.title ?? "Untitled Song")
        return title
    }

    public var fullText: String {
        var fullText = ""
        fullText += combinedTitle + "\n"

        if let subtitle {
            fullText += subtitle + "\n"
        }

        verses.forEach { verse in
            if let verseTitle = verse.title {
                fullText += "\n" + verseTitle
            }

            var mainVerseText = ""
            if verse.isChorus {
                mainVerseText += "Chorus: "
            } else if let verseNumber = verse.number {
                mainVerseText += "\(verseNumber): "
            }
            if let verseText = verse.text {
                mainVerseText += verseText
            }
            fullText += "\n" + mainVerseText

            if let _ = verse.chorusIndex {
                fullText += " Chorus"
            }

            fullText += "\n"
        }

        if let author {
            fullText += "\n" + author
        }

        if let year {
            fullText += "\n" + year
        }

        return fullText
    }

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
