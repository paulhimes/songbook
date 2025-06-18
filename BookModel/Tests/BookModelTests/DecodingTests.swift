@testable import BookModel
import Combine
import Foundation
import Testing

/// Tests for book decoding.
struct DecodingTests {

    /// Test the properties of the default book.
    @Test func decodeDefault() {
        loadBook(for: .default) {
            #expect($0.title == "Red Songbook")
            #expect($0.contactEmail == "feedback@paulhimes.com")
            #expect($0.version == 1)
            #expect(
                $0.updateURL ==
                URL(string: "http://www.paulhimes.com/songbook/default.json")
            )
            #expect($0.sections.count == 2)
            #expect($0.sections[0].title == "Introduction")
            #expect($0.sections[0].songs.count == 1)
            #expect($0.sections[0].songs[0].title == "Welcome to Red Songbook")
            #expect($0.sections[0].songs[0].verses.count == 5)
            #expect($0.sections[0].songs[0].verses[0].chorusIndex == nil)
            #expect(!$0.sections[0].songs[0].verses[0].isChorus)
            #expect($0.sections[0].songs[0].verses[0].number == nil)
            #expect($0.sections[0].songs[0].verses[0].repeatText == nil)
            #expect(
                $0.sections[0].songs[0].verses[0].text ==
                "Red Songbook is a reader for .songbook files."
            )
            #expect($0.sections[0].songs[0].verses[0].title == nil)
            #expect($0.sections[1].songs[18].title == "Twinkle Twinkle Little Star")
            #expect($0.sections[1].songs[18].number == 19)
            #expect($0.sections[1].songs[18].verses.count == 7)
            #expect($0.sections[1].songs[18].verses[0].number == 1)
        }
        failure: {
            Issue.record("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book.
    @Test func decodeMinimal() {
        loadBook(for: .minimal) {
            #expect($0.title == "minimal")
            #expect($0.contactEmail == nil)
            #expect($0.version == 1)
            #expect($0.updateURL == nil)
            #expect($0.sections.count == 0)
        }
        failure: {
            Issue.record("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book with one section.
    @Test func decodeMinimalWithSection() {
        loadBook(for: .minimalWithSection) {
            #expect($0.title == "minimalWithSection")
            #expect($0.contactEmail == nil)
            #expect($0.version == 1)
            #expect($0.updateURL == nil)
            #expect($0.sections.count == 1)
            #expect($0.sections[0].title == nil)
            #expect($0.sections[0].songs.count == 0)
        }
        failure: {
            Issue.record("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book with one section and song.
    @Test func decodeMinimalWithSong() {
        loadBook(for: .minimalWithSong) {
            #expect($0.title == "minimalWithSong")
            #expect($0.contactEmail == nil)
            #expect($0.version == 1)
            #expect($0.updateURL == nil)
            #expect($0.sections.count == 1)
            #expect($0.sections[0].title == nil)
            #expect($0.sections[0].songs.count == 1)
            #expect($0.sections[0].songs[0].author == nil)
            #expect($0.sections[0].songs[0].number == nil)
            #expect($0.sections[0].songs[0].relatedSongs == nil)
            #expect($0.sections[0].songs[0].subtitle == nil)
            #expect($0.sections[0].songs[0].title == nil)
            #expect($0.sections[0].songs[0].verses.count == 0)
            #expect($0.sections[0].songs[0].year == nil)
        }
        failure: {
            Issue.record("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book with one section and song and one verse.
    @Test func decodeMinimalWithVerse() {
        loadBook(for: .minimalWithVerse) {
            #expect($0.title == "minimalWithVerse")
            #expect($0.contactEmail == nil)
            #expect($0.version == 1)
            #expect($0.updateURL == nil)
            #expect($0.sections.count == 1)
            #expect($0.sections[0].title == nil)
            #expect($0.sections[0].songs.count == 1)
            #expect($0.sections[0].songs[0].author == nil)
            #expect($0.sections[0].songs[0].number == nil)
            #expect($0.sections[0].songs[0].relatedSongs == nil)
            #expect($0.sections[0].songs[0].subtitle == nil)
            #expect($0.sections[0].songs[0].title == nil)
            #expect($0.sections[0].songs[0].verses.count == 1)
            #expect($0.sections[0].songs[0].year == nil)
            #expect($0.sections[0].songs[0].verses[0].chorusIndex == nil)
            #expect(!$0.sections[0].songs[0].verses[0].isChorus)
            #expect($0.sections[0].songs[0].verses[0].isChorusInt == nil)
            #expect($0.sections[0].songs[0].verses[0].number == nil)
            #expect($0.sections[0].songs[0].verses[0].repeatText == nil)
            #expect($0.sections[0].songs[0].verses[0].text == nil)
            #expect($0.sections[0].songs[0].verses[0].title == nil)
        }
        failure: {
            Issue.record("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the maximum book with all possible properties used.
    @Test func decodeMaximum() {
        loadBook(for: .maximum) {
            #expect($0.title == "Red Songbook")
            #expect($0.contactEmail == "feedback@paulhimes.com")
            #expect($0.version == 1)
            #expect(
                $0.updateURL ==
                URL(string: "http://www.paulhimes.com/songbook/default.json")
            )
            #expect($0.sections.count == 1)
            #expect($0.sections[0].title == "Introduction")
            #expect($0.sections[0].songs.count == 2)
            #expect($0.sections[0].songs[0].audioFileNames == ["The first song.m4a"])
            #expect($0.sections[0].songs[0].author == "Paul Himes")
            #expect($0.sections[0].songs[0].number == 1)
            #expect($0.sections[0].songs[0].relatedSongs?.count == 1)
            #expect($0.sections[0].songs[0].relatedSongs?[0].sectionIndex == 0)
            #expect($0.sections[0].songs[0].relatedSongs?[0].songIndex == 1)
            #expect($0.sections[0].songs[0].subtitle == "The first song.")
            #expect($0.sections[0].songs[0].title == "Welcome to Red Songbook")
            #expect($0.sections[0].songs[0].verses.count == 2)
            #expect($0.sections[0].songs[0].year == "2020")
            #expect($0.sections[0].songs[0].verses[0].chorusIndex == nil)
            #expect($0.sections[0].songs[0].verses[0].isChorus)
            #expect($0.sections[0].songs[0].verses[0].isChorusInt == 1)
            #expect($0.sections[0].songs[0].verses[0].number == 1)
            #expect($0.sections[0].songs[0].verses[0].repeatText == ".songbook files.")
            #expect(
                $0.sections[0].songs[0].verses[0].text ==
                "Red Songbook is a reader for .songbook files."
            )
            #expect($0.sections[0].songs[0].verses[0].title == "The first verse.")
            #expect($0.sections[0].songs[0].verses[1].chorusIndex == 0)
            #expect(!$0.sections[0].songs[0].verses[1].isChorus)
            #expect($0.sections[0].songs[0].verses[1].isChorusInt == 0)
            #expect($0.sections[0].songs[0].verses[1].number == 2)
            #expect($0.sections[0].songs[0].verses[1].repeatText == "nursery rhymes.")
            #expect(
                $0.sections[0].songs[0].verses[1].text ==
                "The built-in songbook contains children’s songs and nursery rhymes."
            )
            #expect($0.sections[0].songs[0].verses[1].title == "The second verse.")
        }
        failure: {
            Issue.record("Failed to decode book: \($0)")
        }
    }
    
    /// The bad file type should not produce a book.
    @Test func decodeBadContent() {
        loadBook(for: .badContent, fileExtension: "txt") { _ in
            Issue.record("Incorrectly found book in bad content file.")
        }
        failure: {
            #expect(
                $0.localizedDescription ==
                "The data couldn’t be read because it isn’t in the correct format."
            )
        }
    }

    /// The bad JSON file should not produce a book.
    @Test func decodeBadJSON() {
        loadBook(for: .badJSON) { _ in
            Issue.record("Incorrectly found book in bad content file.")
        }
        failure: {
            #expect(
                $0.localizedDescription ==
                "The data couldn’t be read because it is missing."
            )
        }
    }
    
    /// The empty JSON file should not produce a book.
    @Test func decodeEmptyJSON() {
        loadBook(for: .emptyJSON) { _ in
            Issue.record("Incorrectly found book in bad content file.")
        }
        failure: {
            #expect(
                $0.localizedDescription ==
                "The data couldn’t be read because it isn’t in the correct format."
            )
        }
    }
}
