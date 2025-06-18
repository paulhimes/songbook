@testable import BookModel
import Testing

struct PlayableItemIdTests {

    /// The string description should contain the section index, song index, and playable item
    /// index.
    @Test func description() {
        #expect(
            PlayableItemId(sectionIndex: 0, songIndex: 1, playableItemIndex: 2).description ==
            "[0,1,2]"
        )
    }

    /// Initialization with a description string should assign the correct indices.
    @Test func initWithDescription() throws {
        #expect(PlayableItemId("") == nil)
        #expect(PlayableItemId("0") == nil)
        #expect(PlayableItemId("0,1") == nil)
        #expect(PlayableItemId("0,1,2") == nil)
        #expect(PlayableItemId("0,1,2,3") == nil)
        #expect(PlayableItemId("[]") == nil)
        #expect(PlayableItemId("[0]") == nil)
        #expect(PlayableItemId("[0,1]") == nil)
        #expect(PlayableItemId("[0,1,2,3]") == nil)
        #expect(PlayableItemId("[apple,banana,orange]") == nil)
        let id = try #require(PlayableItemId("[0,1,2]"))
        #expect(id.sectionIndex == 0)
        #expect(id.songIndex == 1)
        #expect(id.playableItemIndex == 2)
    }
}
