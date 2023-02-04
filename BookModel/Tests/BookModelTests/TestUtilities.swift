import Combine
import Foundation
import XCTest
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
    testFile: StaticString = #file,
    testLine: UInt = #line
) throws {
    guard let url = Bundle.module.url(
        forResource: file.rawValue,
        withExtension: fileExtension
    ) else {
        XCTFail("Missing test book file: \(file)", file: testFile, line: testLine)
        return
    }

    let originalData = try Data(contentsOf: url)
    let originalBook = try JSONDecoder().decode(Book.self, from: originalData)

    let newData = try JSONEncoder().encode(originalBook)
    let newBook = try JSONDecoder().decode(Book.self, from: newData)

    XCTAssertEqual(newBook, originalBook, file: testFile, line: testLine)
}

/// Gets the URL of a songbook file from the bundle.
/// - Parameters:
///   - file: The name of the songbook file.
///   - testFile: The source file of the caller.
///   - testLine: The source line of the caller.
/// - Returns: The `URL` of a songbook file, or `nil` if the file could not be found.
func url(
    for file: SampleBookSongbookFile,
    testFile: StaticString = #file,
    testLine: UInt = #line
) -> URL? {
    guard let url = Bundle.module.url(
        forResource: file.rawValue,
        withExtension: "songbook"
    ) else {
        XCTFail("Missing test songbook file: \(file)", file: testFile, line: testLine)
        return nil
    }

    return url
}
