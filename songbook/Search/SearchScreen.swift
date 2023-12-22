import BookModel
import Foundation
import SwiftUI

struct SearchScreen: View {

    /// The book model.
    @ObservedObject var bookModel: BookModel

    /// The index of the currently visible page.
    @AppStorage(.StorageKey.currentPageIndex) var currentPageIndex = 0

    /// The current search string.
    @State var searchText = ""

    /// `true` iff the search UI is visible.
    @Binding var searchPresented: Bool

    @FocusState var isSearching: Bool

    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                List {
                    ForEach(
                        bookModel.searchResults(for: searchText)
                    ) { section in
                        Section(section.title) {
                            ForEach(section.results) { searchResult in
                                switch searchResult {
                                case let .exactMatch(number, originalSectionTitle, pageIndex, title):
                                    Button {
                                        currentPageIndex = pageIndex
                                        searchPresented = false
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text("\(originalSectionTitle)")
                                                .foregroundColor(.secondary)
                                            Text("\(number): \(title)")
                                        }
                                        .multilineTextAlignment(.leading)
                                    }
                                case let .partialMatch(
                                    fullTextHighlight,
                                    pageIndex,
                                    partialText
                                ):
                                    Button {
                                        currentPageIndex = pageIndex
                                        searchPresented = false
                                    } label: {
                                        Text(partialText)
                                            .lineLimit(1)
                                            .foregroundColor(.secondary)
                                    }
                                case let .plain(number, pageIndex, title):
                                    Button("\(number ?? ""): \(title)") {
                                        currentPageIndex = pageIndex
                                        searchPresented = false
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 16)
                            VStack(spacing: 0) {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 8, maxHeight: 8)
                                    .onTapGesture {
                                        isSearching = true
                                    }
                                HStack(spacing: 4) {
                                    Image(systemName: "magnifyingglass")
                                        .imageScale(.medium)
                                    ZStack(alignment: .leading) {
                                        Text("Search")
                                            .opacity(searchText.isEmpty ? 1 : 0)
                                        TextField("Search", text: $searchText, prompt: Text(""))
                                            .foregroundStyle(Color.primary)
                                            .focused($isSearching)
                                            .keyboardType(.numbersAndPunctuation)
                                            .autocorrectionDisabled()
                                    }
                                }
                                Color.clear
                                    .contentShape(Rectangle())
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 8, maxHeight: 8)
                                    .onTapGesture {
                                        isSearching = true
                                    }
                            }
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .padding([.leading, .trailing], 6)
                            .background(Color(UIColor.tertiarySystemFill))
                            .cornerRadius(12)
                            Spacer().frame(width: 4)
                            Button(role: .cancel) {
                                searchPresented = false
                            } label: {
                                Text("Cancel")
                            }
                            Spacer().frame(width: 8)
                        }
                        .frame(width: proxy.size.width)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onAppear {
                isSearching = true
            }
        }
    }
}

struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen(bookModel: BookModel(), searchPresented: .constant(true))
    }
}
