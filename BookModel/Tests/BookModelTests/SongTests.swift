import XCTest
@testable import BookModel

final class SongTests: XCTestCase {

    /// Combined title should include song number and title and gracefully fallback or remove
    /// components if either value is missing.
    func testCombinedTitle() {
        XCTAssertEqual(
            Song(
            audioFileNames: nil,
            author: nil,
            number: nil,
            relatedSongs: nil,
            subtitle: nil,
            title: nil,
            verses: [],
            year: nil
            ).combinedTitle,
            "Untitled Song"
        )

        XCTAssertEqual(
            Song(
                audioFileNames: nil,
                author: nil,
                number: 1,
                relatedSongs: nil,
                subtitle: nil,
                title: nil,
                verses: [],
                year: nil
            ).combinedTitle,
            "1: Untitled Song"
        )

        XCTAssertEqual(
            Song(
                audioFileNames: nil,
                author: nil,
                number: nil,
                relatedSongs: nil,
                subtitle: nil,
                title: "Title",
                verses: [],
                year: nil
            ).combinedTitle,
            "Title"
        )

        XCTAssertEqual(
            Song(
                audioFileNames: nil,
                author: nil,
                number: 1,
                relatedSongs: nil,
                subtitle: nil,
                title: "Title",
                verses: [],
                year: nil
            ).combinedTitle,
            "1: Title"
        )

    }

}
