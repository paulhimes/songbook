import Combine
import Foundation
import Zip

/// The interface to access and managing .songbook file data.
@MainActor
public class BookModel: ObservableObject {

    // MARK: Public Properties

    /// The book.
    @Published public var book: Book? {
        didSet {
            index = Index(book: book, audioFileDirectory: .bookDirectory)
        }
    }

    /// The index of the book.
    @Published public var index: Index?

    /// The URL of the songbook file without tunes. `nil` if the book is not loaded.
    public var bookWithoutTunesURL: URL? {
        book?.withoutTunesURL
    }

    /// The URL of the songbook file with tunes. `nil` if the book is not loaded or the book had no
    /// tunes.
    public var bookWithTunesURL: URL? {
        book?.withTunesURL
    }

    // MARK: Public Functions

    /// Initialize a ``BookModel``.
    public init() {
        // Try to load the existing book.
        do {
            book = try loadBook()
        } catch {
            // Failed to load a book, revert to the default book.
            importBook(from: .defaultBook)
        }
    }

    /// Imports a .songbook file at the given ``URL`` into the book directory.
    /// - Parameters:
    ///   - url: The ``URL`` of the .songbook file.
    public func importBook(from url: URL) {
        // Unload the current book.
        book = nil

        Task {
            // The destination is the book directory.
            let destination = URL.bookDirectory

            // Remove the destination directory, if it exists.
            do {
                try FileManager.default.removeItem(at: destination)
            } catch {
                // Ignore errors. This probably failed because the directory doesn't exist.
            }

            do {
                // Unzip all the book files into the destination directory. The directory must not
                // already exist.
                Zip.addCustomFileExtension("songbook")
                try Zip.unzipFile(
                    url,
                    destination: destination,
                    overwrite: true,
                    password: nil
                )

                // Try to load the new book.
                let book = try loadBook()

                // If the book has tunes, copy the original file to the book with tunes location.
                if let bookWithTunesURL = book.withTunesURL {
                    try FileManager.default.createDirectory(
                        at: .bookWithTunesDirectory,
                        withIntermediateDirectories: true
                    )
                    try FileManager.default.moveItem(
                        at: url,
                        to: bookWithTunesURL
                    )
                }

                // Zip just the book.json file and save it to the book without tunes location.
                try FileManager.default.createDirectory(
                    at: .bookWithoutTunesDirectory,
                    withIntermediateDirectories: true
                )
                try Zip.zipFiles(
                    paths: [.book],
                    zipFilePath: book.withoutTunesURL,
                    password: nil,
                    compression: .BestCompression,
                    progress: nil
                )

                // Update the published property after all the steps have succeeded.
                self.book = book
            } catch {
                print("Failed to open book: \(error)")
                if url == .defaultBook {
                    // If it was the default book which failed to load. Stop.
                    return
                } else {
                    // Failed to load a book, revert to the default book.
                    importBook(from: .defaultBook)
                }
            }

            // Remove the input file, if it exists.
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                // Ignore errors. This probably failed because the file was already moved.
            }
        }
    }

    // MARK: Private Functions

    /// Loads the book.
    /// - Returns: The loaded book.
    private func loadBook() throws -> Book {
        let data = try Data.init(contentsOf: .book)
        return try JSONDecoder().decode(Book.self, from: data)
    }
}

extension URL {
    /// `true` iff the ``URL`` points to a directory rather than a file.
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

extension Book {

    // MARK: Public Properties

    var withoutTunesURL: URL {
        return URL.bookWithoutTunesDirectory.appending(
            component: "\(baseFileName) without tunes.songbook"
        )
    }

    var withTunesURL: URL? {
        guard bookHasTunes else {
            return nil
        }
        return URL.bookWithTunesDirectory.appending(
            component: "\(baseFileName) with tunes.songbook"
        )
    }

    // MARK: Private Properties

    /// The base file name which should be used for the loaded book.
    /// - Returns: A file-safe name which includes the title and version number.
    private var baseFileName: String {
        let invalidCharacters = CharacterSet(charactersIn: "\\/:*?\"<>|")
            .union(.newlines)
            .union(.illegalCharacters)
            .union(.controlCharacters)
        var safeFileName = title.components(separatedBy: invalidCharacters).joined()
        if safeFileName.isEmpty {
            safeFileName = "Songbook"
        }

        return "\(safeFileName) (v\(version))"
    }

    /// `true` iff we can see multiple files in the book directory.
    private var bookHasTunes: Bool {
        do {
            let fileCount = try FileManager.default.contentsOfDirectory(
                at: URL.bookDirectory,
                includingPropertiesForKeys: []
            ).filter { !$0.isDirectory }.count
            return fileCount > 1
        } catch {
            return false
        }
    }
}
