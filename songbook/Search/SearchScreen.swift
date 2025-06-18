import BookModel
import Foundation
import SwiftUI

struct SearchScreen: View {

    /// The book model.
    var bookModel: BookModel

    /// The index of the currently visible page.
    @AppStorage(.StorageKey.currentPageIndex) var currentPageIndex = 0

    /// The current search string.
    @State var searchText = ""

    /// `true` iff the search UI is visible.
    @Binding var searchPresented: Bool
    
    /// Controls the focus of the text field. This mechanism doesn't currently work if you create 
    /// this in the SearchBar, so we create it here and pass it in.
    @FocusState var isSearching: Bool

    var body: some View {
        NavigationStack {
            SearchResultsView(
                bookModel: bookModel,
                currentPageIndex: $currentPageIndex,
                searchPresented: $searchPresented,
                searchText: searchText
            )
            .searchable(text: $searchText, isPresented: $searchPresented)
            .searchFocused($isSearching)
            .onAppear {
                Task {
                    try? await Task.sleep(for: .zero)
                    isSearching = true
                }
            }
        }
        .statusBarHidden(true)
    }
}

#Preview {
    @Previewable @State var searchPresented: Bool = true
    SearchScreen(bookModel: BookModel(), searchPresented: $searchPresented)
}
