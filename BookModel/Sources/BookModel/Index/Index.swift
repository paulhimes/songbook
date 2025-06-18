import Foundation
import UniformTypeIdentifiers

/// Provides cached access to the book model including any queries or custom views into the model.
public struct Index {

    // MARK: Internal Properties
    
    /// The book.
    let book: Book

    /// The URL of the songbook file without tunes.
    let bookWithoutTunesURL: URL

    /// The URL of the songbook file with tunes. `nil` if the book has no tunes.
    let bookWithTunesURL: URL?

    /// The page models for the book.
    let pageModels: [PageModel]

    /// An ordered array of playable items.
    let playableItems: [PlayableItem]

    /// The ``PlayableItem``s grouped by page index.
    let playableItemsForPageIndex: [Int: [PlayableItem]]

    /// The page index for each ``PlayableItemId``.
    let pageIndexForPlayableItemId: [PlayableItemId: Int]

    /// Pre-computed array of unfiltered search results.
    let searchResultSections: [SearchResultSection]

    // MARK: Private Properties

    /// An array of search items grouped by section.
    private let searchItems: [(String, [SearchItem])]

    /// The extensions of supported audio file formats.
    private static let supportedAudioFileExtensions = ["m4a", "mp3", "wav", "caf"]

    // MARK: Public Functions

    /// Initialize an index from a book model.
    /// - Parameters:
    ///   - book: The book model.
    ///   - audioFileDirectory: The directory containing the audio files corresponding to
    ///     the given book.
    init?(book: Book?, audioFileDirectory: URL) {
        print("Start Indexing…")
        let start = Date.now
        guard let book else { return nil }

        self.book = book
        bookWithoutTunesURL = book.withoutTunesURL
        bookWithTunesURL = book.withTunesURL

        // Generate the playable items.
        var audioFiles = [String: URL]()
        if let directoryEnumerator = FileManager.default
            .enumerator(at: audioFileDirectory, includingPropertiesForKeys: nil) {
            audioFiles = directoryEnumerator
                .compactMap { $0 as? URL }
                .filter { Index.supportedAudioFileExtensions.contains($0.pathExtension) }
                .reduce([:], { partialResult, audioFile in
                    var combined = partialResult
                    combined[audioFile.deletingPathExtension().lastPathComponent] = audioFile
                    return combined
                })

        }
        playableItems = book.sections.enumerated().flatMap { sectionIndex, section in
            section.songs.enumerated().flatMap { songIndex, song in
                let indexedFileName = "\(sectionIndex)-\(songIndex)"
                let audioFileNames: [String] = song.audioFileNames ?? audioFiles.keys
                    .filter { $0 == indexedFileName || $0.hasPrefix("\(indexedFileName)-") }
                    .sorted()
                return audioFileNames
                    .compactMap { audioFiles[$0] }
                    .enumerated()
                    .map { playableItemIndex, url in
                        PlayableItem(
                            albumTitle: section.title,
                            albumTrackCount: section.songs.count,
                            albumTrackNumber: songIndex + 1,
                            audioFileURL: url,
                            author: song.author,
                            id: PlayableItemId(
                                sectionIndex: sectionIndex,
                                songIndex: songIndex,
                                playableItemIndex: playableItemIndex
                            ),
                            songId: SongId(sectionIndex: sectionIndex, songIndex: songIndex),
                            title: song.combinedTitle
                        )
                    }
            }
        }

        // Generate the page models, search items, and search tokens.
        var pageModels: [PageModel] = []
        var searchItemsBySection: [(String, [SearchItem])] = []
        pageModels.append(.book(title: book.title, version: book.version))
        book.sections.enumerated().forEach { sectionIndex, section in
            var searchItems: [SearchItem] = []
            pageModels.append(.section(title: section.title ?? "Untitled Section"))
            section.songs.enumerated().forEach { songIndex, song in
                pageModels.append(
                    .song(
                        text: song.fullText,
                        songId: SongId(sectionIndex: sectionIndex, songIndex: songIndex)
                    )
                )
                searchItems.append(
                    SearchItem(
                        fullText: song.fullText,
                        number: song.number.map { "\($0)" },
                        pageIndex: pageModels.count - 1,
                        title: song.title ?? "Untitled Song",
                        tokens: song.fullText.tokens
                    )
                )
            }

            searchItemsBySection.append((section.title ?? "Untitled Section", searchItems))
        }
        self.pageModels = pageModels
        self.searchItems = searchItemsBySection

        // Pre-compute the list of all unfiltered search results.
        searchResultSections = searchItems.map { sectionTitle, searchItems in
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
        }

        // Group playable items by page index.
        var playableItemsForPageIndex: [Int: [PlayableItem]] = [:]
        var pageIndexForPlayableItemId: [PlayableItemId: Int] = [:]
        for playableItem in playableItems {
            let index = pageModels.firstIndex { pageModel in
                if case let .song(_, id) = pageModel, id == playableItem.songId {
                    return true
                } else {
                    return false
                }
            }
            if let index {
                var playableItemsOnPage = playableItemsForPageIndex[index] ?? []
                playableItemsOnPage.append(playableItem)
                playableItemsForPageIndex[index] = playableItemsOnPage

                pageIndexForPlayableItemId[playableItem.id] = index
            }
        }
        self.playableItemsForPageIndex = playableItemsForPageIndex
        self.pageIndexForPlayableItemId = pageIndexForPlayableItemId

        print("Indexing took \(Date.now.timeIntervalSince(start)) seconds.")
    }

    // Mark: - Search

    /// Search for matching ``Song``s by song number.
    ///
    /// - Parameter numbersOnly: The number to search for. Search results for all ``Song``s where
    ///   the `number` contains the search string will be returned.
    /// - Returns: The matching ``SearchResult``s grouped by ``SearchResultSection``.
    ///
    func searchByNumber(_ numbersOnly: String) -> [SearchResultSection] {
        var exactMatches: [SearchResult] = []
        var sections: [SearchResultSection] = searchItems.compactMap { sectionTitle, searchItems in
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
        }

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
    func searchByText(_ searchString: String) async -> [SearchResultSection] {
        let searchTokens = searchString.tokens

        var sections: [SearchResultSection] = []
        for (sectionTitle, searchItems) in searchItems {
            let results: [SearchResult] = await searchItems.parallelFlatMap { searchItem in
                Index.searchResults(for: searchTokens, in: searchItem)
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
    func searchResults(for searchString: String) async -> [SearchResultSection] {
        var sections: [SearchResultSection]

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
            sections = searchResultSections
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
    nonisolated private static func searchResults(
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

extension String {
    var tokens: [SearchToken] {
        var tokens: [SearchToken] = []
        var partialToken = ""
        var tokenStartIndex: Int?
        var tokenEndIndex: Int?
        for (index, character) in enumerated() {
            if character.isLetter {
                if partialToken.isEmpty {
                    tokenStartIndex = index
                }
                tokenEndIndex = index
                partialToken.append(character)
            } else if character.isWhitespace {
                if !partialToken.isEmpty, let tokenStartIndex, let tokenEndIndex {
                    tokens.append(
                        SearchToken(
                            text: partialToken,
                            startIndex: tokenStartIndex,
                            endIndex: tokenEndIndex
                        )
                    )
                }
                partialToken = ""
                tokenStartIndex = nil
                tokenEndIndex = nil
            }
        }

        if !partialToken.isEmpty, let tokenStartIndex, let tokenEndIndex {
            tokens.append(
                SearchToken(
                    text: partialToken,
                    startIndex: tokenStartIndex,
                    endIndex: tokenEndIndex
                )
            )
        }
        return tokens
    }
}
