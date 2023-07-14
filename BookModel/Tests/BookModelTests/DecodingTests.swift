import Combine
import XCTest
@testable import BookModel

/// Tests for book decoding.
final class DecodingTests: XCTestCase {
    
    /// Test the properties of the default book.
    func testDecodeDefault() {
        loadBook(for: .default) {
            XCTAssertEqual($0.title, "Red Songbook")
            XCTAssertEqual($0.contactEmail, "feedback@paulhimes.com")
            XCTAssertEqual($0.version, 1)
            XCTAssertEqual(
                $0.updateURL,
                URL(string: "http://www.paulhimes.com/songbook/default.json")
            )
            XCTAssertEqual($0.sections.count, 2)
            XCTAssertEqual($0.sections[0].title, "Introduction")
            XCTAssertEqual($0.sections[0].songs.count, 1)
            XCTAssertEqual($0.sections[0].songs[0].title, "Welcome to Red Songbook")
            XCTAssertEqual($0.sections[0].songs[0].verses.count, 5)
            XCTAssertNil($0.sections[0].songs[0].verses[0].chorusIndex)
            XCTAssertFalse($0.sections[0].songs[0].verses[0].isChorus)
            XCTAssertNil($0.sections[0].songs[0].verses[0].number)
            XCTAssertNil($0.sections[0].songs[0].verses[0].repeatText)
            XCTAssertEqual(
                $0.sections[0].songs[0].verses[0].text,
                "Red Songbook is a reader for .songbook files."
            )
            XCTAssertNil($0.sections[0].songs[0].verses[0].title)
            XCTAssertEqual($0.sections[1].songs[18].title, "Twinkle Twinkle Little Star")
            XCTAssertEqual($0.sections[1].songs[18].number, 19)
            XCTAssertEqual($0.sections[1].songs[18].verses.count, 7)
            XCTAssertEqual($0.sections[1].songs[18].verses[0].number, 1)
        }
        failure: {
            XCTFail("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book.
    func testDecodeMinimal() {
        loadBook(for: .minimal) {
            XCTAssertEqual($0.title, "minimal")
            XCTAssertNil($0.contactEmail)
            XCTAssertEqual($0.version, 1)
            XCTAssertNil($0.updateURL)
            XCTAssertEqual($0.sections.count, 0)
        }
        failure: {
            XCTFail("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book with one section.
    func testDecodeMinimalWithSection() {
        loadBook(for: .minimalWithSection) {
            XCTAssertEqual($0.title, "minimalWithSection")
            XCTAssertNil($0.contactEmail)
            XCTAssertEqual($0.version, 1)
            XCTAssertNil($0.updateURL)
            XCTAssertEqual($0.sections.count, 1)
            XCTAssertNil($0.sections[0].title)
            XCTAssertEqual($0.sections[0].songs.count, 0)
        }
        failure: {
            XCTFail("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book with one section and song.
    func testDecodeMinimalWithSong() {
        loadBook(for: .minimalWithSong) {
            XCTAssertEqual($0.title, "minimalWithSong")
            XCTAssertNil($0.contactEmail)
            XCTAssertEqual($0.version, 1)
            XCTAssertNil($0.updateURL)
            XCTAssertEqual($0.sections.count, 1)
            XCTAssertNil($0.sections[0].title)
            XCTAssertEqual($0.sections[0].songs.count, 1)
            XCTAssertNil($0.sections[0].songs[0].author)
            XCTAssertNil($0.sections[0].songs[0].number)
            XCTAssertNil($0.sections[0].songs[0].relatedSongs)
            XCTAssertNil($0.sections[0].songs[0].subtitle)
            XCTAssertNil($0.sections[0].songs[0].title)
            XCTAssertEqual($0.sections[0].songs[0].verses.count, 0)
            XCTAssertNil($0.sections[0].songs[0].year)
        }
        failure: {
            XCTFail("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the minimal book with one section and song and one verse.
    func testDecodeMinimalWithVerse() {
        loadBook(for: .minimalWithVerse) {
            XCTAssertEqual($0.title, "minimalWithVerse")
            XCTAssertNil($0.contactEmail)
            XCTAssertEqual($0.version, 1)
            XCTAssertNil($0.updateURL)
            XCTAssertEqual($0.sections.count, 1)
            XCTAssertNil($0.sections[0].title)
            XCTAssertEqual($0.sections[0].songs.count, 1)
            XCTAssertNil($0.sections[0].songs[0].author)
            XCTAssertNil($0.sections[0].songs[0].number)
            XCTAssertNil($0.sections[0].songs[0].relatedSongs)
            XCTAssertNil($0.sections[0].songs[0].subtitle)
            XCTAssertNil($0.sections[0].songs[0].title)
            XCTAssertEqual($0.sections[0].songs[0].verses.count, 1)
            XCTAssertNil($0.sections[0].songs[0].year)
            XCTAssertNil($0.sections[0].songs[0].verses[0].chorusIndex)
            XCTAssertFalse($0.sections[0].songs[0].verses[0].isChorus)
            XCTAssertNil($0.sections[0].songs[0].verses[0].isChorusInt)
            XCTAssertNil($0.sections[0].songs[0].verses[0].number)
            XCTAssertNil($0.sections[0].songs[0].verses[0].repeatText)
            XCTAssertNil($0.sections[0].songs[0].verses[0].text)
            XCTAssertNil($0.sections[0].songs[0].verses[0].title)
        }
        failure: {
            XCTFail("Failed to decode book: \($0)")
        }
    }
    
    /// Test the properties of the maximum book with all possible properties used.
    func testDecodeMaximum() {
        loadBook(for: .maximum) {
            XCTAssertEqual($0.title, "Red Songbook")
            XCTAssertEqual($0.contactEmail, "feedback@paulhimes.com")
            XCTAssertEqual($0.version, 1)
            XCTAssertEqual(
                $0.updateURL,
                URL(string: "http://www.paulhimes.com/songbook/default.json")
            )
            XCTAssertEqual($0.sections.count, 1)
            XCTAssertEqual($0.sections[0].title, "Introduction")
            XCTAssertEqual($0.sections[0].songs.count, 2)
            XCTAssertEqual($0.sections[0].songs[0].audioFileNames, ["The first song.m4a"])
            XCTAssertEqual($0.sections[0].songs[0].author, "Paul Himes")
            XCTAssertEqual($0.sections[0].songs[0].number, 1)
            XCTAssertEqual($0.sections[0].songs[0].relatedSongs?.count, 1)
            XCTAssertEqual($0.sections[0].songs[0].relatedSongs?[0].sectionIndex, 0)
            XCTAssertEqual($0.sections[0].songs[0].relatedSongs?[0].songIndex, 1)
            XCTAssertEqual($0.sections[0].songs[0].subtitle, "The first song.")
            XCTAssertEqual($0.sections[0].songs[0].title, "Welcome to Red Songbook")
            XCTAssertEqual($0.sections[0].songs[0].verses.count, 2)
            XCTAssertEqual($0.sections[0].songs[0].year, "2020")
            XCTAssertNil($0.sections[0].songs[0].verses[0].chorusIndex)
            XCTAssertTrue($0.sections[0].songs[0].verses[0].isChorus)
            XCTAssertEqual($0.sections[0].songs[0].verses[0].isChorusInt, 1)
            XCTAssertEqual($0.sections[0].songs[0].verses[0].number, 1)
            XCTAssertEqual($0.sections[0].songs[0].verses[0].repeatText, ".songbook files.")
            XCTAssertEqual(
                $0.sections[0].songs[0].verses[0].text,
                "Red Songbook is a reader for .songbook files."
            )
            XCTAssertEqual($0.sections[0].songs[0].verses[0].title, "The first verse.")
            XCTAssertEqual($0.sections[0].songs[0].verses[1].chorusIndex, 0)
            XCTAssertFalse($0.sections[0].songs[0].verses[1].isChorus)
            XCTAssertEqual($0.sections[0].songs[0].verses[1].isChorusInt, 0)
            XCTAssertEqual($0.sections[0].songs[0].verses[1].number, 2)
            XCTAssertEqual($0.sections[0].songs[0].verses[1].repeatText, "nursery rhymes.")
            XCTAssertEqual(
                $0.sections[0].songs[0].verses[1].text,
                "The built-in songbook contains children’s songs and nursery rhymes."
            )
            XCTAssertEqual($0.sections[0].songs[0].verses[1].title, "The second verse.")
        }
        failure: {
            XCTFail("Failed to decode book: \($0)")
        }
    }
    
    /// The bad file type should not produce a book.
    func testDecodeBadContent() {
        loadBook(for: .badContent, fileExtension: "txt") { _ in
            XCTFail("Incorrectly found book in bad content file.")
        }
        failure: {
            XCTAssertEqual(
                $0.localizedDescription,
                "The data couldn’t be read because it isn’t in the correct format."
            )
        }
    }

    /// The bad JSON file should not produce a book.
    func testDecodeBadJSON() {
        loadBook(for: .badJSON) { _ in
            XCTFail("Incorrectly found book in bad content file.")
        }
        failure: {
            XCTAssertEqual(
                $0.localizedDescription,
                "The data couldn’t be read because it is missing."
            )
        }
    }
    
    /// The empty JSON file should not produce a book.
    func testDecodeEmptyJSON() {
        loadBook(for: .emptyJSON) { _ in
            XCTFail("Incorrectly found book in bad content file.")
        }
        failure: {
            XCTAssertEqual(
                $0.localizedDescription,
                "The data couldn’t be read because it isn’t in the correct format."
            )
        }
    }
}
