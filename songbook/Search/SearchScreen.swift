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
        GeometryReader { proxy in
            NavigationStack {
                SearchResults(
                    bookModel: bookModel,
                    currentPageIndex: $currentPageIndex,
                    searchPresented: $searchPresented,
                    searchText: searchText
                )
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        SearchBar(
                            isSearching: _isSearching,
                            searchPresented: $searchPresented,
                            searchText: $searchText,
                            width: proxy.size.width
                        )
                    }
                }
            }
        }
        .statusBarHidden(true)
    }
}

struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen(bookModel: BookModel(), searchPresented: .constant(true))
    }
}
