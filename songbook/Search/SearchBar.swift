import SwiftUI

struct SearchBar: View {

    /// Controls the focus of the text field.
    @FocusState var isSearching: Bool

    /// `true` iff the search UI is visible.
    @Binding var searchPresented: Bool

    /// The current search text is used to perform searches.
    @Binding var searchText: String

    /// The width of the search bar.
    var width: Double

    var body: some View {
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
        .frame(width: width)
        .onAppear {
            isSearching = true
        }
    }
}

#Preview {
    Color.clear.toolbar {
        SearchBar(searchPresented: .constant(true), searchText: .constant(""), width: 500)
    }
}
