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
            .song(text: "Welcome to Red Songbook\n\nRed Songbook is a reader for .songbook files.\n\nThe built-in songbook contains children’s songs and nursery rhymes.\n\nYou can open new songbooks from email attachments or the internet. When you open a new songbook, your old songbook will be replaced.\n\nUse AirDrop to share a songbook with people nearby:\nhttp://support.apple.com/kb/ht5887\n\nFound a typo? Select the text and choose “Report Problem…”\n", songId: SongId(sectionIndex: 0, songIndex: 0)),
            .section(title: "Sample Songs"),
            .song(text: "1: A Tisket A Tasket\n\nA-tisket a-tasket\nA green and yellow basket\nI wrote a letter to my love\nAnd on the way I dropped it,\nI dropped it,\nI dropped it,\nAnd on the way I dropped it.\nA little boy he picked it up and put it in his pocket.\n", songId: SongId(sectionIndex: 1, songIndex: 0)),
            .song(text: "2: Hickory Dickory Dock\n\nHickory, dickory, dock,\nThe mouse ran up the clock.\nThe clock struck one,\nThe mouse ran down,\nHickory, dickory, dock.\n", songId: SongId(sectionIndex: 1, songIndex: 1)),
            .song(text: "3: The Farmer in the Dell\n\n1: The farmer in the dell\nThe farmer in the dell\nHeigh-ho, the derry-o\nThe farmer in the dell\n\n2: The farmer takes a wife\nThe farmer takes a wife\nHeigh-ho, the derry-o\nThe farmer takes a wife\n\n3: The wife takes the child\nThe wife takes the child\nHeigh-ho, the derry-o\nThe wife takes the child\n\n4: The child takes the nurse\nThe child takes the nurse\nHeigh-ho, the derry-o\nThe child takes the nurse\n\n5: The nurse takes the cow\nThe nurse takes the cow\nHeigh-ho, the derry-o\nThe nurse takes the cow\n\n6: The cow takes the dog\nThe cow takes the dog\nHeigh-ho, the derry-o\nThe cow takes the dog\n\n7: The dog takes the cat\nThe dog takes the cat\nHeigh-ho, the derry-o\nThe dog takes the cat\n\n8: The cat takes the mouse\nThe cat takes the mouse\nHeigh-ho, the derry-o\nThe cat takes the mouse\n\n9: The mouse takes the cheese\nThe mouse takes the cheese\nHeigh-ho, the derry-o\nThe mouse takes the cheese\n\n10: The cheese stands alone\nThe cheese stands alone\nHeigh-ho, the derry-o\nThe cheese stands alone\n", songId: SongId(sectionIndex: 1, songIndex: 2)),
            .song(text: "4: Hey Diddle Diddle\n\nHey diddle diddle,\nThe Cat and the fiddle,\nThe Cow jumped over the moon.\nThe little Dog laughed,\nTo see such sport,\nAnd the Dish ran away with the Spoon.\n", songId: SongId(sectionIndex: 1, songIndex: 3)),
            .song(text: "5: Humpty Dumpty\n\nHumpty Dumpty sat on a wall,\nHumpty Dumpty had a great fall.\nAll the king’s horses and all the king’s men\nCouldn’t put Humpty together again.\n", songId: SongId(sectionIndex: 1, songIndex: 4)),
            .song(text: "6: Hush, Little Baby\n\n1: Hush, little baby, don’t say a word,\nMama’s gonna buy you a mockingbird.\n\n2: And if that mockingbird won’t sing,\nMama’s gonna buy you a diamond ring.\n\n3: And if that diamond ring turns brass,\nMama’s gonna buy you a looking glass.\n\n4: And if that looking glass gets broke,\nMama’s gonna buy you a billy goat.\n\n5: And if that billy goat won’t pull,\nMama’s gonna buy you a cart and bull.\n\n6: And if that cart and bull turn over,\nMama’s gonna buy you a dog named Rover.\n\n7: And if that dog named Rover won’t bark,\nMama’s gonna buy you a horse and cart.\n\n8: And if that horse and cart fall down,\nYou’ll still be the sweetest little baby in town.\n", songId: SongId(sectionIndex: 1, songIndex: 5)),
            .song(text: "7: Jack and Jill\n\nJack and Jill went up the hill\nTo fetch a pail of water.\nJack fell down and broke his crown,\nAnd Jill came tumbling after.\n", songId: SongId(sectionIndex: 1, songIndex: 6)),
            .song(text: "8: Jack Be Nimble\n\nJack be nimble,\nJack be quick,\nJack jump over\nThe candlestick.\n", songId: SongId(sectionIndex: 1, songIndex: 7)),
            .song(text: "9: Little Bo Peep\n\nLittle Bo-Peep has lost her sheep,\nAnd doesn’t know where to find them;\nLeave them alone, And they’ll come home,\nWagging their tails behind them.\n", songId: SongId(sectionIndex: 1, songIndex: 8)),
            .song(text: "10: Little Miss Muffet\n\nLittle Miss Muffet\nSat on a tuffet,\nEating her curds and whey;\nAlong came a spider,\nWho sat down beside her\nAnd frightened Miss Muffet away.\n", songId: SongId(sectionIndex: 1, songIndex: 9)),
            .song(text: "11: London Bridge\n\nLondon Bridge is falling down,\nFalling down, falling down.\nLondon Bridge is falling down,\nMy fair lady.\n", songId: SongId(sectionIndex: 1, songIndex: 10)),
            .song(text: "12: Mary Had a Little Lamb\n\n1: Mary had a little lamb,\nlittle lamb, little lamb,\nMary had a little lamb,\nwhose fleece was white as snow.\n\n2: And everywhere that Mary went,\nMary went, Mary went,\nAnd everywhere that Mary went,\nthe lamb was sure to go.\n\n3: He followed her to school one day,\nschool one day, school one day\nHe followed her to school one day,\nwhich was against the rule.\n\n4: It made the children laugh and play,\nlaugh and play, laugh and play,\nIt made the children laugh and play,\nto see a lamb at school.\n\n5: And so the teacher turned it out,\nturned it out, turned it out,\nAnd so the teacher turned it out,\nbut still it lingered near.\n\n6: And waited patiently about,\n’ly about, ’ly about,\nAnd waited patiently about,\ntill Mary did appear.\n\n7: “Why does the lamb love Mary so?”\nMary so, Mary so,\n“Why does the lamb love Mary so?”\nthe eager children cry.\n\n8: “Why, Mary loves the lamb, you know.”\nlamb, you know, lamb, you know,\n“Why, Mary loves the lamb, you know.”\nthe teacher did reply.\n", songId: SongId(sectionIndex: 1, songIndex: 11)),
            .song(text: "13: Oh My Darling, Clementine\n\n1: In a cavern, in a canyon,\nExcavating for a mine\nDwelt a miner forty niner,\nAnd his daughter Clementine.\n\nChorus: Oh my darling, oh my darling, Oh my darling, Clementine! Thou art lost and gone forever Dreadful sorry, Clementine.\n\n2: Light she was and like a fairy,\nAnd her shoes were number nine\nHerring boxes, without topses,\nSandals were for Clementine. Chorus\n\n3: Drove she ducklings to the water\nEv’ry morning just at nine,\nHit her foot against a splinter,\nFell into the foaming brine. Chorus\n\n4: Ruby lips above the water,\nBlowing bubbles, soft and fine,\nBut, alas, I was no swimmer,\nSo I lost my Clementine. Chorus\n", songId: SongId(sectionIndex: 1, songIndex: 12)),
            .song(text: "14: Patty Cake\n\nPatty cake, patty cake, baker’s man.\nBake me a cake as fast as you can;\nRoll it, and Pat it, and mark it with a B,\nAnd put it in the oven for baby and me.\n", songId: SongId(sectionIndex: 1, songIndex: 13)),
            .song(text: "15: Pop Goes the Weasel\n\nAll around the mulberry bush\nThe monkey chased the weasel;\nThe monkey thought ’twas all in fun,\nPop! goes the weasel.\n", songId: SongId(sectionIndex: 1, songIndex: 14)),
            .song(text: "16: Ring Around the Rosie\n\nRing-a-round the rosie,\nA pocket full of posies,\nAshes! Ashes!\nWe all fall down.\n", songId: SongId(sectionIndex: 1, songIndex: 15)),
            .song(text: "17: Rock-a-bye Baby\n\nRock-a-bye baby, on the treetop,\nWhen the wind blows, the cradle will rock,\nWhen the bough breaks, the cradle will fall,\nAnd down will come baby, cradle and all.\n", songId: SongId(sectionIndex: 1, songIndex: 16)),
            .song(text: "18: Row, Row, Row Your Boat\n\nRow, row, row your boat,\nGently down the stream.\nMerrily, merrily, merrily, merrily,\nLife is but a dream.\n", songId: SongId(sectionIndex: 1, songIndex: 17)),
            .song(text: "19: Twinkle Twinkle Little Star\n\n1: Twinkle, twinkle, little star,\nHow I wonder what you are.\nUp above the world so high,\nLike a diamond in the sky.\n\n2: When the blazing sun is gone,\nWhen he nothing shines upon,\nThen you show your little light,\nTwinkle, twinkle, all the night.\n\n3: Then the traveller in the dark,\nThanks you for your tiny spark,\nHe could not see which way to go,\nIf you did not twinkle so.\n\n4: In the dark blue sky you keep,\nAnd often through my curtains peep,\nFor you never shut your eye,\n’Till the sun is in the sky.\n\n5: As your bright and tiny spark,\nLights the traveller in the dark.\nThough I know not what you are,\nTwinkle, twinkle, little star.\n\n6: Twinkle, twinkle, little star.\nHow I wonder what you are.\nUp above the world so high,\nLike a diamond in the sky.\n\n7: Twinkle, twinkle, little star.\nHow I wonder what you are.\n", songId: SongId(sectionIndex: 1, songIndex: 18)),
        ]

        await withCheckedContinuation { continuation in
            withObservationTracking {
                _ = subject.index
            } onChange: {
                continuation.resume()
            }

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
                .song(text: "1: First Audio Sample\n\nTap the action button in the lower right corner. Then choose “Play Tune” to begin audio playback.\n\nThis is a sample audio file. The audio will continue playing after the app is backgrounded. You can even control playback using the control center remote controls. Red songbook supports single song playback, single song repeated playback, and continuous song playback.\n", songId: SongId(sectionIndex: 0, songIndex: 0)),
                .song(text: "2: Second Audio Sample\n\nThis is the second sample audio file. When continuous playback mode is selected, the next song file will play when the previous file ends. You can change the playback mode by tapping the playback mode button in the lower right corner while a file is playing.\n", songId: SongId(sectionIndex: 0, songIndex: 1)),
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
