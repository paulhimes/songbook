import BookModel
import SwiftUI

/// A container view for every possible type of search result view on the search screen.
struct SearchResultItemView: View {
    
    /// The action to perform when the item is tapped.
    let action: (Int) -> Void

    /// The search result data model for the view.
    let searchResult: SearchResult
    
    /// Initialize a ``SearchResultItemView`` with a search result and tap action.
    /// - Parameters:
    ///   - searchResult: The search result data model for the view.
    ///   - action: The action to perform when the item is tapped.
    init(searchResult: SearchResult, action: @escaping (Int) -> Void) {
        self.action = action
        self.searchResult = searchResult
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch searchResult {
            case let .exactMatch(number, originalSectionTitle, pageIndex, title):
                ExactMatchItemView(
                    originalSectionTitle: originalSectionTitle,
                    number: number,
                    title: title
                ) {
                    action(pageIndex)
                }
            case let .partialMatch(fullTextHighlight, pageIndex, partialText, partialTextHighlight):
                PartialItemView(partialText: partialText, partialTextHighlight: partialTextHighlight) {
                    action(pageIndex)
                }
            case let .plain(number, pageIndex, title):
                PlainItemView(number: number, title: title) {
                    action(pageIndex)
                }
            }
        }
    }
}

#Preview {
    SearchResultItemView(searchResult: .plain(number: "1", pageIndex: 0, title: "Title")) { _ in }
}
