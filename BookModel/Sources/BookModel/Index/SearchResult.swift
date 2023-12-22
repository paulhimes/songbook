import Foundation

/// The data model for a single item in the results list of the search screen.
public enum SearchResult {
    /// An item with a number exactly matching the search string. Used during a number-based search.
    /// - Parameters:
    ///   - number: The number of the search item.
    ///   - originalSectionTitle: The title of the item's ``Section`` in the ``Book``.
    ///   - pageIndex: The index of the item's page.
    ///   - title: The title of the item.
    case exactMatch(number: String, originalSectionTitle: String, pageIndex: Int, title: String)

    /// An item partially matching the search string at a specific range. Used to show partial item
    /// content during a text-based search.
    /// - Parameters:
    ///   - fullTextHighlight: The highlighted range in the item's full text.
    ///   - pageIndex: The index of the item's page.
    ///   - partialText: Partial text of the item including the matching range.
    case partialMatch(
        fullTextHighlight: ClosedRange<Int>,
        pageIndex: Int,
        partialText: AttributedString
    )

    /// An item matching the search string without a specific matching range. Used when the search
    /// string is empty. Also used to show item titles during a text-based search.
    /// - Parameters:
    ///   - number: The number of the search item.
    ///   - pageIndex: The index of the item's page.
    ///   - title: The title of the item.
    case plain(number: String?, pageIndex: Int, title: String)

    /// The index of the item's page.
    var pageIndex: Int {
        switch self {
        case .exactMatch(_, _, let pageIndex, _):
            return pageIndex
        case .partialMatch(_, let pageIndex, _):
            return pageIndex
        case .plain(_, let pageIndex, _):
            return pageIndex
        }
    }
}

extension SearchResult: Identifiable {
    public var id: String {
        switch self {
        case let .exactMatch(_, _, pageIndex, _):
            "ExactMatch-\(pageIndex)"
        case let .partialMatch(fullTextHighlight, pageIndex, _):
            "PartialMatch-\(pageIndex)-[\(fullTextHighlight.lowerBound),\(fullTextHighlight.upperBound)]"
        case let .plain(_, pageIndex, _):
            "Plain-\(pageIndex)"
        }
    }
}
