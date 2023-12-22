import Foundation

/// A collection of ``SearchResult``s grouped under a section title.
public struct SearchResultSection {
    /// The ``SearchResult`` items in the section.
    public let results: [SearchResult]

    /// The name of the ``SearchResultSection``.
    public let title: String

    /// Initialize a ``SearchResultSection``.
    /// - Parameters:
    ///   - title: The title of the section.
    ///   - results: The search results within the section.
    init(title: String, results: [SearchResult]) {
        self.title = title
        self.results = results
    }
}

extension SearchResultSection: Identifiable {
    public var id: String {
        title
    }
}
