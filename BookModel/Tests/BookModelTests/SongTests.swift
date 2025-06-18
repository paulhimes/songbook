@testable import BookModel
import Testing

struct SongTests {

    /// Combined title should include song number and title and gracefully fallback or remove
    /// components if either value is missing.
    @Test func combinedTitle() {
        #expect(
            Song(
            audioFileNames: nil,
            author: nil,
            number: nil,
            relatedSongs: nil,
            subtitle: nil,
            title: nil,
            verses: [],
            year: nil
            ).combinedTitle ==
            "Untitled Song"
        )

        #expect(
            Song(
                audioFileNames: nil,
                author: nil,
                number: 1,
                relatedSongs: nil,
                subtitle: nil,
                title: nil,
                verses: [],
                year: nil
            ).combinedTitle ==
            "1: Untitled Song"
        )

        #expect(
            Song(
                audioFileNames: nil,
                author: nil,
                number: nil,
                relatedSongs: nil,
                subtitle: nil,
                title: "Title",
                verses: [],
                year: nil
            ).combinedTitle ==
            "Title"
        )

        #expect(
            Song(
                audioFileNames: nil,
                author: nil,
                number: 1,
                relatedSongs: nil,
                subtitle: nil,
                title: "Title",
                verses: [],
                year: nil
            ).combinedTitle ==
            "1: Title"
        )

    }

}
