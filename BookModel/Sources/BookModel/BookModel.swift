import Combine
import Foundation
import Observation
import OSLog
import SwiftUI
import Zip

/// The interface to access and managing .songbook file data.
@Observable
public class BookModel {

    // MARK: Public Properties

    /// The book.
    public var book: Book? {
        index?.book
    }

    /// The index of the book.
    private(set) var index: Index?

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
    ///
    /// - Parameter url: The ``URL`` of the .songbook file.
    ///
    public func importBook(from url: URL) async {
        // Unload the current book index.
        index = nil

        // Asynchronously load and index a new book from the given `URL`.
        let book = await Task { importBookWithFallback(from: url) }.value
        index = Index(book: book, audioFileDirectory: .bookDirectory)
    }

    /// Searches for ``Song``s that match the given search string. If the search string is empty, a
    /// single ``SearchResult`` for every ``Song`` will be returned. If the search string contains
    /// only numbers, ``Songs`` will be searched by their number only. If the search string contains
    /// letters, a fuzzy match search algorithm will be used to find portions of ``Song``s which
    /// match the search string.
    ///
    /// - Parameter searchString: The string to search for.
    /// - Returns: An array of ``SearchResultSection``s containing ``SearchResult``s for matching
    ///   ``Song``s.
    ///
    public func searchResults(for searchString: String) async -> [SearchResultSection] {
        var sections: [SearchResultSection] = []

        // Determine search mode.

        let lettersOnly = searchString
            .components(separatedBy: CharacterSet.letters.inverted)
            .joined()

        let numbersOnly = searchString
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()

        if !lettersOnly.isEmpty {
            // If the search string contains any letters, do a text-based search.
            sections = await searchByText(searchString)
        } else if !numbersOnly.isEmpty {
            // If the search string contains any numbers and no letters, do a number-based search.
            sections = searchByNumber(numbersOnly)
        } else {
            // Otherwise return all items.
            sections = index?.searchItems.map { sectionTitle, searchItems in
                SearchResultSection(
                    title: sectionTitle,
                    results: searchItems.map {
                        SearchResult.plain(
                            number: $0.number,
                            pageIndex: $0.pageIndex,
                            title: $0.title
                        )
                    }
                )
            } ?? []
        }

        return sections
    }

    // MARK: Private Functions

    /// Imports the songbook file at the given `URL` and returns the loaded ``Book``.
    ///
    /// - Parameter url: The `URL` of the new book.
    /// - Returns: The new loaded ``Book``.
    ///
    private func importBookWithFallback(from url: URL) -> Book? {
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
    ///
    /// - Returns: The loaded book.
    ///
    private func loadBook() throws -> Book {
        let data = try Data.init(contentsOf: .book)
        return try JSONDecoder().decode(Book.self, from: data)
    }
    
    /// Search for matching ``Song``s by song number.
    ///
    /// - Parameter numbersOnly: The number to search for. Search results for all ``Song``s where
    ///   the `number` contains the search string will be returned.
    /// - Returns: The matching ``SearchResult``s grouped by ``SearchResultSection``.
    ///
    private func searchByNumber(_ numbersOnly: String) -> [SearchResultSection] {
        var exactMatches: [SearchResult] = []
        var sections: [SearchResultSection] = index?.searchItems.compactMap { sectionTitle, searchItems in
            let results: [SearchResult] = searchItems.compactMap {
                guard let number = $0.number, number.contains(numbersOnly) else { return nil }

                // Exact matches are included in their sections and a combined section.
                if number == numbersOnly {
                    exactMatches.append(
                        .exactMatch(
                            number: number,
                            originalSectionTitle: sectionTitle,
                            pageIndex: $0.pageIndex,
                            title: $0.title
                        )
                    )
                }

                return SearchResult.plain(
                    number: $0.number,
                    pageIndex: $0.pageIndex,
                    title: $0.title
                )
            }

            guard !results.isEmpty else { return nil }

            return SearchResultSection(
                title:sectionTitle,
                results: results
            )
        } ?? []

        // Add back the exact matches in a combined section.
        let exactMatchPageIndices = exactMatches.map { $0.pageIndex }
        let resultsPageIndices = sections.flatMap { $0.results.map { $0.pageIndex } }
        let allMatchesAreExact = resultsPageIndices.allSatisfy {
            exactMatchPageIndices.contains($0)
        }
        if !exactMatches.isEmpty && !allMatchesAreExact  {
            sections.insert(SearchResultSection(title: "Exact Matches", results: exactMatches), at: 0)
        }

        return sections
    }

    /// Search for matching ``Song``s by text content.
    ///
    /// - Parameter searchString: The substring to search for. The fuzzy match algorithm is used to
    ///   find parts of ``Song``s which match the substring.
    /// - Returns: The matching ``SearchResult``s grouped by ``SearchResultSection``.
    ///
    private func searchByText(_ searchString: String) async -> [SearchResultSection] {
        let searchTokens = searchString.tokens

        var sections: [SearchResultSection] = []
        for (sectionTitle, searchItems) in index?.searchItems ?? [] {
            let results: [SearchResult] = await searchItems.parallelFlatMap { searchItem in
                BookModel.searchResults(for: searchTokens, in: searchItem)
            }

            guard !results.isEmpty else { continue }

            sections.append(
                SearchResultSection(
                    title: sectionTitle,
                    results: results
                )
            )
        }
        return sections
    }
    
    /// Generates an array of ``SearchResult``s if the ``SearchItem`` contains any matching ranges
    /// of tokens.
    ///
    /// - Parameters:
    ///   - searchTokens: The tokens to search for.
    ///   - searchItem: The item to search within.
    /// - Returns: The relevant ``SearchResult``s including a `partialMatch` for each matching token
    ///   range and a `plain` if there were any matching ranges.
    ///
    private static func searchResults(
        for searchTokens: [SearchToken],
        in searchItem: SearchItem
    ) -> [SearchResult] {
        var results: [SearchResult] = []

        // Use the searchTokens to find matching ranges in the tokens array.
        let matchingRanges = searchItem.tokens.ranges(of: searchTokens)

        // Convert the matching subsequences into index ranges in the song.
        let indexRanges: [ClosedRange<Int>] = matchingRanges.compactMap {
            let tokensInRange = searchItem.tokens[$0]
            guard let first = tokensInRange.first, let last = tokensInRange.last else {
                return nil
            }
            return first.startIndex...last.endIndex
        }

        // If there are any ranges, generate a plain SearchResult.
        if !indexRanges.isEmpty {
            results.append(
                SearchResult.plain(
                    number: searchItem.number,
                    pageIndex: searchItem.pageIndex,
                    title: searchItem.title
                )
            )
        }

        // For each range, generate a partialMatch SearchResult.
        indexRanges.forEach {
            let text = searchItem.fullText.suffix(
                from: searchItem.fullText.index(
                    searchItem.fullText.startIndex,
                    offsetBy: $0.lowerBound
                )
            )
            results.append(
                SearchResult.partialMatch(
                    fullTextHighlight: $0,
                    pageIndex: searchItem.pageIndex,
                    partialText: "…\(text)",
                    partialTextHighlight: 1...$0.upperBound + 1 - $0.lowerBound
                )
            )
        }

        return results
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
    ///
    /// - Returns: A file-safe name which includes the title and version number.
    ///
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
