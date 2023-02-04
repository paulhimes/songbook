import XCTest
@testable import BookModel

/// Tests for book encoding.
final class EncodingTests: XCTestCase {

    /// Tests encoding for the default book.
    func testEncodeDefault() throws {
        try roundTrip(for: .default)
    }

    /// Tests encoding for the maximum book.
    func testEncodeMaximum() throws {
        try roundTrip(for: .maximum)
    }

    /// Tests encoding for the minimal book.
    func testEncodeMinimal() throws {
        try roundTrip(for: .minimal)
    }

    /// Tests encoding for the minimal book with a section.
    func testEncodeMinimalWithSection() throws {
        try roundTrip(for: .minimalWithSection)
    }

    /// Tests encoding for the minimal book with a song.
    func testEncodeMinimalWithSong() throws {
        try roundTrip(for: .minimalWithSong)
    }

    /// Tests encoding for the minimal book with a verse.
    func testEncodeMinimalWithVerse() throws {
        try roundTrip(for: .minimalWithVerse)
    }
}
