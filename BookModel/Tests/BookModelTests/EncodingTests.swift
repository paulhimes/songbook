@testable import BookModel
import Testing

/// Tests for book encoding.
struct EncodingTests {

    /// Tests encoding for the default book.
    @Test func encodeDefault() throws {
        try roundTrip(for: .default)
    }

    /// Tests encoding for the maximum book.
    @Test func encodeMaximum() throws {
        try roundTrip(for: .maximum)
    }

    /// Tests encoding for the minimal book.
    @Test func encodeMinimal() throws {
        try roundTrip(for: .minimal)
    }

    /// Tests encoding for the minimal book with a section.
    @Test func encodeMinimalWithSection() throws {
        try roundTrip(for: .minimalWithSection)
    }

    /// Tests encoding for the minimal book with a song.
    @Test func encodeMinimalWithSong() throws {
        try roundTrip(for: .minimalWithSong)
    }

    /// Tests encoding for the minimal book with a verse.
    @Test func encodeMinimalWithVerse() throws {
        try roundTrip(for: .minimalWithVerse)
    }
}
