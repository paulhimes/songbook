import XCTest
@testable import BookModel

@MainActor
final class BookModelTests: XCTestCase {

    let destination = URL.temporaryDirectory.appending(component: "testBook")
    var subject: BookModel!

    override func setUp() {
        subject = BookModel()
    }

    override func tearDown() {
        subject = nil
        do {
            try FileManager.default.removeItem(at: .bookDirectory)
        } catch {
            // Ignore errors.
        }
    }

    /// The badContent file should fail to load and revert to the default book.
    func testImportBadContent() async {
        guard let url = url(for: .badContent) else { return }

        await subject.importBook(from: url)

        XCTAssertEqual(subject.book?.title, "Red Songbook")
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path()))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookDirectory.appending(component: "default.songbook").path()
            )
        )
    }

    /// The badJSON file should fail to load and revert to the default book.
    func testImportBadJSON() async {
        guard let url = url(for: .badJSON) else { return }

        await subject.importBook(from: url)

        XCTAssertEqual(subject.book?.title, "Red Songbook")
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path()))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookDirectory.appending(component: "default.songbook").path()
            )
        )
    }

    /// The default file should successfully load.
    func testImportDefault() async {
        guard let url = url(for: .default) else { return }

        await subject.importBook(from: url)

        XCTAssertEqual(subject.book?.title, "Red Songbook")
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path()))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookDirectory.appending(component: "default.songbook").path()
            )
        )
    }

    /// The emptyJSON file should fail to load.
    func testImportEmptyJSON() async {
        guard let url = url(for: .emptyJSON) else { return }

        await subject.importBook(from: url)

        XCTAssertEqual(subject.book?.title, "Red Songbook")
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path()))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookDirectory.appending(component: "default.songbook").path()
            )
        )
    }

    /// The notZip file should fail to load.
    func testImportNotZip() async {
        guard let url = url(for: .notZip) else { return }

        await subject.importBook(from: url)

        XCTAssertEqual(subject.book?.title, "Red Songbook")
        XCTAssertTrue(FileManager.default.fileExists(atPath: URL.book.path()))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: URL.bookDirectory.appending(component: "default.songbook").path()
            )
        )
    }
}
