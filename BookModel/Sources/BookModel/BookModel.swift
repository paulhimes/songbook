import Combine
import Foundation
import os.log
import Zip

/// The interface to access and managing .songbook file data.
@MainActor
public class BookModel: ObservableObject {

    // MARK: Public Properties

    /// The index of the book.
    @Published public var index: Index?

    /// The page models for the book.
    public var pageModels: [PageModel] {
        index?.pageModels ?? []
    }

    /// An ordered array of playable items.
    public var playableItems: [PlayableItem] {
        index?.playableItems ?? []
    }

    /// The ``PlayableItem``s grouped by page index.
    public var playableItemsForPageIndex: [Int: [PlayableItem]] {
        index?.playableItemsForPageIndex ?? [:]
    }

    /// The page index for each ``PlayableItemId``.
    public var pageIndexForPlayableItemId: [PlayableItemId: Int] {
        index?.pageIndexForPlayableItemId ?? [:]
    }

    /// The `URL` of the songbook file to use for sharing.
    public var shareBookURL: URL? {
        index?.bookWithTunesURL ?? index?.bookWithoutTunesURL
    }

    // MARK: Public Functions

    /// Initialize a ``BookModel``.
    public init() {
        // Try to load and index the existing book.
        do {
            let book = try loadBook()
            index = Index(book: book, audioFileDirectory: .bookDirectory)
        } catch {
            // Failed to load a book, revert to the default book.
            Task {
                await importBook(from: .defaultBook)
            }
        }
    }

    /// Imports a .songbook file at the given ``URL`` into the book directory.
    /// - Parameters:
    ///   - url: The ``URL`` of the .songbook file.
    public func importBook(from url: URL) async {
        // Unload the current book index.
        index = nil

        // Asynchronously load and index a new book from the given `URL`.
        let book = await Task { importBookWithFallback(from: url) }.value
        index = Index(book: book, audioFileDirectory: .bookDirectory)
    }

    // MARK: Private Functions

    /// Imports the songbook file at the given `URL` and returns the loaded ``Book``.
    /// - Parameter url: The `URL` of the new book.
    /// - Returns: The new loaded ``Book``.
    func importBookWithFallback(from url: URL) -> Book? {
        let bookDirectory = URL.bookDirectory

        // Remove the book directory, if it exists.
        do {
            try FileManager.default.removeItem(at: bookDirectory)
            Logger.auto().log("Removed the book directory.")
        } catch {
            // Ignore errors. This probably failed because the directory doesn't exist.
        }

        do {
            // Unzip all the book files into the book directory. The directory must not already
            // exist.
            Zip.addCustomFileExtension("songbook")
            try Zip.unzipFile(
                url,
                destination: bookDirectory,
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
                if url.isInBundle {
                    // Copy bundle books and leave the original in place.
                    try FileManager.default.copyItem(
                        at: url,
                        to: bookWithTunesURL
                    )
                    Logger.auto().log("Copied a bundled book.")
                } else {
                    // Move non-bundle books.
                    try FileManager.default.moveItem(
                        at: url,
                        to: bookWithTunesURL
                    )
                    Logger.auto().log("Moved a non-bundled book.")
                }
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

            Logger.auto().log("Zipped file to path: \(book.withoutTunesURL)")

            if !url.isInBundle {
                // Remove the input file, if it exists.
                do {
                    try FileManager.default.removeItem(at: url)
                    Logger.auto().log("Removed the imported file at \(url)")
                } catch {
                    // Ignore errors. This probably failed because the file was already moved.
                }
            }

            // Return the book after all the steps have succeeded.
            return book
        } catch {
            Logger.auto().log("Failed to open book: \(error)")
            if url == .defaultBook {
                // If it was the default book which failed to load. Stop.
                return nil
            } else {
                // Failed to load a book, revert to the default book.
                return importBookWithFallback(from: .defaultBook)
            }
        }
    }

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

    /// `true` iff the `URL` points to a file in the app bundle.
    var isInBundle: Bool {
        path(percentEncoded: false).hasPrefix(
            Bundle(for: BookModel.self).bundleURL.path(percentEncoded: false)
        )
    }
}

extension Book {

    // MARK: Public Properties

    /// The `URL` of the version of the book with no tunes.
    var withoutTunesURL: URL {
        return URL.bookWithoutTunesDirectory.appending(
            component: "\(baseFileName) without tunes.songbook"
        )
    }

    /// The `URL` of the version of the book with tunes (if it exists).
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
