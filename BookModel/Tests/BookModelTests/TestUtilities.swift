import Combine
import Foundation
import Testing
@testable import BookModel

/// Load the book file which corresponds to the given `SampleBookJsonFile`.
/// - Parameters:
///   - file: The name of the test book file.
///   - fileExtension: The extension of the test book file.
///   - success: Called when loading succeeds.
///   - failure: Called when loading fails.
func loadBook(
    for file: SampleBookJsonFile,
    fileExtension: String = "json",
    success: @escaping (Book) -> Void,
    failure: @escaping (Error) -> Void
) {
    guard let url = Bundle.module.url(
        forResource: file.rawValue,
        withExtension: fileExtension
    ) else {
        failure(BookModelTestError.missingFile)
        return
    }

    _ = Just(url)
        .tryMap { try Data(contentsOf: $0) }
        .decode(type: Book.self, decoder: JSONDecoder())
        .sink { sinkResult in
            switch sinkResult {
            case .failure(let error):
                failure(error)
            case .finished:
                break
            }
        } receiveValue: {
            success($0)
        }
}

/// Decode a book json file then encode and decode again to get another copy of the book. Make sure
/// both book copies are equal.
/// - Parameters:
///   - file: The name of the test book file.
///   - fileExtension: the extension of the test book file.
///   - testFile: The source file of the caller.
///   - testLine: The source line of the caller.
/// - Throws: An error if any step fails.
func roundTrip(
    for file: SampleBookJsonFile,
    fileExtension: String = "json",
    testFileID: String = #fileID,
    testFilePath: String = #filePath,
    testFileLine: Int = #line,
    testFileColumn: Int = #column
) throws {
    let sourceLocation = SourceLocation(
        fileID: testFileID,
        filePath: testFilePath,
        line: testFileLine,
        column: testFileColumn
    )

    guard let url = Bundle.module.url(
        forResource: file.rawValue,
        withExtension: fileExtension
    ) else {
        Issue.record("Missing test book file: \(file)", sourceLocation: sourceLocation)
        return
    }

    let originalData = try Data(contentsOf: url)
    let originalBook = try JSONDecoder().decode(Book.self, from: originalData)

    let newData = try JSONEncoder().encode(originalBook)
    let newBook = try JSONDecoder().decode(Book.self, from: newData)

    #expect(newBook == originalBook, sourceLocation: sourceLocation)
}

/// Gets the URL of a songbook file from the bundle.
/// - Parameters:
///   - file: The name of the songbook file.
///   - testFile: The source file of the caller.
///   - testLine: The source line of the caller.
/// - Returns: The ``URL`` of a songbook file, or `nil` if the file could not be found.
func url(
    for file: SampleBookSongbookFile,
    testFileID: String = #fileID,
    testFilePath: String = #filePath,
    testFileLine: Int = #line,
    testFileColumn: Int = #column
) -> URL? {
    guard let url = Bundle.module.url(
        forResource: file.rawValue,
        withExtension: "songbook"
    ) else {
        Issue.record(
            "Missing test songbook file: \(file)",
            sourceLocation: SourceLocation(
                fileID: testFileID,
                filePath: testFilePath,
                line: testFileLine,
                column: testFileColumn
            )
        )
        return nil
    }

    return url
}
