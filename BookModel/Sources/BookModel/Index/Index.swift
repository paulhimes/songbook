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
    
    /// An array of search items grouped by section.
    let searchItems: [(String, [SearchItem])]

    // MARK: Private Properties

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
