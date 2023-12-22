@testable import BookModel
import XCTest

@MainActor
final class BookModelTests: XCTestCase {

    let destination = URL.temporaryDirectory.appending(component: "testBook")
    var subject: BookModel!
    var defaultPageModels: [PageModel] = []

    override func setUp() async throws {
        subject = BookModel()
        defaultPageModels = [
            .book(title: "Red Songbook", version: 1),
            .section(title: "Introduction"),
            .song(text: "Welcome to Red Songbook", songId: SongId(sectionIndex: 0, songIndex: 0)),
            .section(title: "Sample Songs"),
            .song(text: "1: A Tisket A Tasket", songId: SongId(sectionIndex: 1, songIndex: 0)),
            .song(text: "2: Hickory Dickory Dock", songId: SongId(sectionIndex: 1, songIndex: 1)),
            .song(text: "3: The Farmer in the Dell", songId: SongId(sectionIndex: 1, songIndex: 2)),
            .song(text: "4: Hey Diddle Diddle", songId: SongId(sectionIndex: 1, songIndex: 3)),
            .song(text: "5: Humpty Dumpty", songId: SongId(sectionIndex: 1, songIndex: 4)),
            .song(text: "6: Hush, Little Baby", songId: SongId(sectionIndex: 1, songIndex: 5)),
            .song(text: "7: Jack and Jill", songId: SongId(sectionIndex: 1, songIndex: 6)),
            .song(text: "8: Jack Be Nimble", songId: SongId(sectionIndex: 1, songIndex: 7)),
            .song(text: "9: Little Bo Peep", songId: SongId(sectionIndex: 1, songIndex: 8)),
            .song(text: "10: Little Miss Muffet", songId: SongId(sectionIndex: 1, songIndex: 9)),
            .song(text: "11: London Bridge", songId: SongId(sectionIndex: 1, songIndex: 10)),
            .song(text: "12: Mary Had a Little Lamb", songId: SongId(sectionIndex: 1, songIndex: 11)),
            .song(text: "13: Oh My Darling, Clementine", songId: SongId(sectionIndex: 1, songIndex: 12)),
            .song(text: "14: Patty Cake", songId: SongId(sectionIndex: 1, songIndex: 13)),
            .song(text: "15: Pop Goes the Weasel", songId: SongId(sectionIndex: 1, songIndex: 14)),
            .song(text: "16: Ring Around the Rosie", songId: SongId(sectionIndex: 1, songIndex: 15)),
            .song(text: "17: Rock-a-bye Baby", songId: SongId(sectionIndex: 1, songIndex: 16)),
            .song(text: "18: Row, Row, Row Your Boat", songId: SongId(sectionIndex: 1, songIndex: 17)),
            .song(text: "19: Twinkle Twinkle Little Star", songId: SongId(sectionIndex: 1, songIndex: 18)),
        ]
        for await index in subject.$index.values where index != nil {
            break
        }
    }

    override func tearDown() {
        subject = nil
        defaultPageModels = []
        do {
            try FileManager.default.removeItem(at: .bookDirectory)
        } catch {
            // Ignore errors.
        }
    }

    /// The badContent file should fail to load and revert to the default book.
    func testImportBadContent() async throws {
        guard let url = url(for: .badContent) else { return }

        await subject.importBook(from: url)

        guard case let .book(title, version) = subject.pageModels.first else {
            return XCTFail("First page was not a book page.")
        }
        XCTAssertEqual(title, "Red Songbook")
        XCTAssertEqual(version, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path(percentEncoded: false)))

        let path = URL.bookWithoutTunesDirectory
            .appending(component: "Red Songbook (v1) without tunes.songbook")
            .path(percentEncoded: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        XCTAssertEqual(
            subject.index?.bookWithoutTunesURL,
            URL.bookWithoutTunesDirectory.appending(
                component: "Red Songbook (v1) without tunes.songbook"
            )
        )
        XCTAssertNil(subject.index?.bookWithTunesURL)
        XCTAssertEqual(subject.index?.pageModels, defaultPageModels)
        XCTAssertEqual(subject.index?.playableItems, [])
        XCTAssertEqual(subject.index?.playableItemsForPageIndex, [:])
        XCTAssertEqual(subject.index?.pageIndexForPlayableItemId, [:])
    }

    /// The badJSON file should fail to load and revert to the default book.
    func testImportBadJSON() async {
        guard let url = url(for: .badJSON) else { return }

        await subject.importBook(from: url)

        guard case let .book(title, version) = subject.pageModels.first else {
            return XCTFail("First page was not a book page.")
        }
        XCTAssertEqual(title, "Red Songbook")
        XCTAssertEqual(version, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path(percentEncoded: false)))
        let path = URL.bookWithoutTunesDirectory
            .appending(component: "Red Songbook (v1) without tunes.songbook")
            .path(percentEncoded: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        XCTAssertEqual(
            subject.index?.bookWithoutTunesURL,
            URL.bookWithoutTunesDirectory.appending(
                component: "Red Songbook (v1) without tunes.songbook"
            )
        )
        XCTAssertNil(subject.index?.bookWithTunesURL)
        XCTAssertEqual(subject.index?.pageModels, defaultPageModels)
        XCTAssertEqual(subject.index?.playableItems, [])
        XCTAssertEqual(subject.index?.playableItemsForPageIndex, [:])
        XCTAssertEqual(subject.index?.pageIndexForPlayableItemId, [:])
    }

    /// The default file should successfully load.
    func testImportDefault() async {
        guard let url = url(for: .default) else { return }

        await subject.importBook(from: url)

        guard case let .book(title, version) = subject.pageModels.first else {
            return XCTFail("First page was not a book page.")
        }
        XCTAssertEqual(title, "Red Songbook")
        XCTAssertEqual(version, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path(percentEncoded: false)))
        let path = URL.bookWithoutTunesDirectory
            .appending(component: "Red Songbook (v1) without tunes.songbook")
            .path(percentEncoded: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        XCTAssertEqual(
            subject.index?.bookWithoutTunesURL,
            URL.bookWithoutTunesDirectory.appending(
                component: "Red Songbook (v1) without tunes.songbook"
            )
        )
        XCTAssertNil(subject.index?.bookWithTunesURL)
        XCTAssertEqual(subject.index?.pageModels, defaultPageModels)
        XCTAssertEqual(subject.index?.playableItems, [])
        XCTAssertEqual(subject.index?.playableItemsForPageIndex, [:])
        XCTAssertEqual(subject.index?.pageIndexForPlayableItemId, [:])
    }

    /// The emptyJSON file should fail to load.
    func testImportEmptyJSON() async {
        guard let url = url(for: .emptyJSON) else { return }

        await subject.importBook(from: url)

        guard case let .book(title, version) = subject.pageModels.first else {
            return XCTFail("First page was not a book page.")
        }
        XCTAssertEqual(title, "Red Songbook")
        XCTAssertEqual(version, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path(percentEncoded: false)))
        let path = URL.bookWithoutTunesDirectory
            .appending(component: "Red Songbook (v1) without tunes.songbook")
            .path(percentEncoded: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        XCTAssertEqual(
            subject.index?.bookWithoutTunesURL,
            URL.bookWithoutTunesDirectory.appending(
                component: "Red Songbook (v1) without tunes.songbook"
            )
        )
        XCTAssertNil(subject.index?.bookWithTunesURL)
        XCTAssertEqual(subject.index?.pageModels, defaultPageModels)
        XCTAssertEqual(subject.index?.playableItems, [])
        XCTAssertEqual(subject.index?.playableItemsForPageIndex, [:])
        XCTAssertEqual(subject.index?.pageIndexForPlayableItemId, [:])
    }

    /// The notZip file should fail to load.
    func testImportNotZip() async {
        guard let url = url(for: .notZip) else { return }

        await subject.importBook(from: url)

        guard case let .book(title, version) = subject.pageModels.first else {
            return XCTFail("First page was not a book page.")
        }
        XCTAssertEqual(title, "Red Songbook")
        XCTAssertEqual(version, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path(percentEncoded: false)))
        let path = URL.bookWithoutTunesDirectory
            .appending(component: "Red Songbook (v1) without tunes.songbook")
            .path(percentEncoded: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        XCTAssertEqual(
            subject.index?.bookWithoutTunesURL,
            URL.bookWithoutTunesDirectory.appending(
                component: "Red Songbook (v1) without tunes.songbook"
            )
        )
        XCTAssertNil(subject.index?.bookWithTunesURL)
        XCTAssertEqual(subject.index?.pageModels, defaultPageModels)
        XCTAssertEqual(subject.index?.playableItems, [])
        XCTAssertEqual(subject.index?.playableItemsForPageIndex, [:])
        XCTAssertEqual(subject.index?.pageIndexForPlayableItemId, [:])
    }

    /// When a book with tunes is imported, it's book and audio files should be placed in the
    /// correct locations.
    func testImportWithTunes() async {
        guard let url = url(for: .withTunes) else { return }

        await subject.importBook(from: url)

        guard case let .book(title, version) = subject.pageModels.first else {
            return XCTFail("First page was not a book page.")
        }
        XCTAssertEqual(title, "App Review Sample Book With Audio")
        XCTAssertEqual(version, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path(percentEncoded: false)))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookWithoutTunesDirectory
                    .appending(
                        component: "App Review Sample Book With Audio (v1) without tunes.songbook"
                    )
                    .path(percentEncoded: false)
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookWithTunesDirectory
                    .appending(
                        component: "App Review Sample Book With Audio (v1) with tunes.songbook"
                    )
                    .path(percentEncoded: false)
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookDirectory
                    .appending(component: "0-0.m4a")
                    .path(percentEncoded: false)
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookDirectory
                    .appending(component: "0-1.m4a")
                    .path(percentEncoded: false)
            )
        )

        XCTAssertEqual(
            subject.index?.bookWithoutTunesURL,
            URL.bookWithoutTunesDirectory.appending(
                component: "App Review Sample Book With Audio (v1) without tunes.songbook"
            )
        )
        XCTAssertEqual(
            subject.index?.bookWithTunesURL,
            URL.bookWithTunesDirectory.appending(
                component: "App Review Sample Book With Audio (v1) with tunes.songbook"
            )
        )
        XCTAssertEqual(
            subject.index?.pageModels,
            [
                .book(title: "App Review Sample Book With Audio", version: 1),
                .section(title: "Sample “Songs” With Audio"),
                .song(text: "1: First Audio Sample", songId: SongId(sectionIndex: 0, songIndex: 0)),
                .song(text: "2: Second Audio Sample", songId: SongId(sectionIndex: 0, songIndex: 1)),
                .section(title: "Untitled Section"),
            ]
        )
        XCTAssertEqual(
            subject.index?.playableItems,
            [
                PlayableItem(
                    albumTitle: "Sample “Songs” With Audio",
                    albumTrackCount: 2,
                    albumTrackNumber: 1,
                    audioFileURL: URL.bookDirectory.appending(component: "0-0.m4a"),
                    author: nil,
                    id: PlayableItemId(sectionIndex: 0, songIndex: 0, playableItemIndex: 0),
                    songId: SongId(sectionIndex: 0, songIndex: 0),
                    title: "1: First Audio Sample"
                ),
                PlayableItem(
                    albumTitle: "Sample “Songs” With Audio",
                    albumTrackCount: 2,
                    albumTrackNumber: 2,
                    audioFileURL: URL.bookDirectory.appending(component: "0-1.m4a"),
                    author: nil,
                    id: PlayableItemId(sectionIndex: 0, songIndex: 1, playableItemIndex: 0),
                    songId: SongId(sectionIndex: 0, songIndex: 1),
                    title: "2: Second Audio Sample"
                ),
            ]
        )
        XCTAssertEqual(
            subject.index?.playableItemsForPageIndex,
            [
                3: [
                    PlayableItem(
                        albumTitle: "Sample “Songs” With Audio",
                        albumTrackCount: 2,
                        albumTrackNumber: 2,
                        audioFileURL: URL.bookDirectory.appending(component: "0-1.m4a"),
                        author: nil,
                        id: PlayableItemId(sectionIndex: 0, songIndex: 1, playableItemIndex: 0),
                        songId: SongId(sectionIndex: 0, songIndex: 1),
                        title: "2: Second Audio Sample"
                    )
                ],
                2: [
                    PlayableItem(
                        albumTitle: "Sample “Songs” With Audio",
                        albumTrackCount: 2,
                        albumTrackNumber: 1,
                        audioFileURL: URL.bookDirectory.appending(component: "0-0.m4a"),
                        author: nil,
                        id: PlayableItemId(sectionIndex: 0, songIndex: 0, playableItemIndex: 0),
                        songId: SongId(sectionIndex: 0, songIndex: 0),
                        title: "1: First Audio Sample"
                    )
                ],
            ]
        )
        XCTAssertEqual(
            subject.index?.pageIndexForPlayableItemId,
            [
                PlayableItemId(sectionIndex: 0, songIndex: 0, playableItemIndex: 0): 2,
                PlayableItemId(sectionIndex: 0, songIndex: 1, playableItemIndex: 0): 3,
            ]
        )
    }
}
