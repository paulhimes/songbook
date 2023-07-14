import XCTest
@testable import BookModel

final class PlayableItemIdTests: XCTestCase {

    /// The string description should contain the section index, song index, and playable item
    /// index.
    func testDescription() {
        XCTAssertEqual(
            PlayableItemId(sectionIndex: 0, songIndex: 1, playableItemIndex: 2).description,
            "[0,1,2]"
        )
    }

    /// Initialization with a description string should assign the correct indices.
    func testInitWithDescription() throws {
        XCTAssertNil(PlayableItemId(""))
        XCTAssertNil(PlayableItemId("0"))
        XCTAssertNil(PlayableItemId("0,1"))
        XCTAssertNil(PlayableItemId("0,1,2"))
        XCTAssertNil(PlayableItemId("0,1,2,3"))
        XCTAssertNil(PlayableItemId("[]"))
        XCTAssertNil(PlayableItemId("[0]"))
        XCTAssertNil(PlayableItemId("[0,1]"))
        XCTAssertNil(PlayableItemId("[0,1,2,3]"))
        XCTAssertNil(PlayableItemId("[apple,banana,orange]"))
        let id = try XCTUnwrap(PlayableItemId("[0,1,2]"))
        XCTAssertEqual(id.sectionIndex, 0)
        XCTAssertEqual(id.songIndex, 1)
        XCTAssertEqual(id.playableItemIndex, 2)
    }
}
