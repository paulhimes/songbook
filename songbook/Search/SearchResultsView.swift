import BookModel
import SwiftUI

/// A scrolling list of search results. This was refactored into a separate view to bypass an SDK
/// bug which caused extra view reloads: FB13547604
struct SearchResultsView: View {

    /// The book model.
    var bookModel: BookModel

    /// The index of the currently visible page. We can't use AppStorage directly here due to an SDK
    /// bug which caused extra view reloads: FB13547604
    @Binding var currentPageIndex: Int

    /// Displays the duration of the latest search for debugging purposes.
    @State var searchDuration = ""

    /// Used to dismiss the search screen.
    @Binding var searchPresented: Bool

    /// The currently showing search results.
    @State var searchResults: [SearchResultSection] = []

    /// The current search text is used to perform searches.
    var searchText: String

    var body: some View {
        List {
            ForEach(
                searchResults
            ) { section in
                Section(section.title) {
                    ForEach(section.results) { searchResult in
                        SearchResultItemView(searchResult: searchResult) { pageIndex in
                            currentPageIndex = pageIndex
                            searchPresented = false
                        }
                    }
                }
            }
        }
        .overlay(alignment: .topLeading) {
            Text(searchDuration)
                .font(.caption)
                .opacity(0.5)
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .task(id: searchText) {
            let start = Date.now
            searchResults = await bookModel.searchResults(for: searchText)
            let duration = Date.now.timeIntervalSince(start)
            searchDuration = "\(duration) seconds; \(searchResults.reduce(into: 0) { $0 += $1.results.count }) results"
        }
    }
}

#Preview {
    SearchResultsView(
        bookModel: BookModel(),
        currentPageIndex: .constant(0),
        searchPresented: .constant(true),
        searchText: ""
    )
}
