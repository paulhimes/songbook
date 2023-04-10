import Foundation
import UniformTypeIdentifiers

/// Provides external access to the book model including any queries or custom views into the model.
public struct Index {

    // MARK: Public Properties

    /// The page models for the book.
    public let pageModels: [PageModel]

    /// An ordered array of playable items.
    public let playableItems: [PlayableItem]

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
        guard let book else { return nil }

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
        playableItems = book.sections.enumerated().flatMap { (sectionIndex, section) in
            section.songs.enumerated().flatMap { (songIndex, song) in
                let indexedFileName = "\(sectionIndex)-\(songIndex)"
                let audioFileNames: [String] = song.audioFileNames ?? audioFiles.keys
                    .filter { $0 == indexedFileName || $0.hasPrefix("\(indexedFileName)-") }
                    .sorted()
                return audioFileNames
                    .compactMap { audioFiles[$0] }
                    .map {
                        PlayableItem(
                            audioFileURL: $0,
                            songId: SongId(
                                sectionIndex: sectionIndex,
                                songIndex: songIndex
                            ),
                            title: song.title
                        )
                    }
            }
        }

        // Generate the page models.
        var pageModels: [PageModel] = []
        pageModels.append(.book(title: book.title, version: book.version))
        for section in book.sections {
            pageModels.append(.section(title: section.title ?? "Untitled Section"))
            for song in section.songs {
                var title = ""
                if let number = song.number {
                    title.append("\(number): ")
                }
                title.append(song.title ?? "Untitled Song")
                pageModels.append(.song(title: title))
            }
        }
        self.pageModels = pageModels
    }
}
