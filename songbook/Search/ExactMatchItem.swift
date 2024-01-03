import SwiftUI

/// The view for an exactly matching search item by number with a song title, number, and section
/// title.
struct ExactMatchItem: View {
    
    /// The action to perform when the item is tapped.
    let action: () -> Void

    /// The title of the song's section in the book.
    let originalSectionTitle: String

    /// The number of the song.
    let number: String

    /// The title of the song.
    let title: String
    
    /// Initializes an ``ExactMatchItem``.
    /// - Parameters:
    ///   - originalSectionTitle: The title of the song's section in the book.
    ///   - number: The number of the song.
    ///   - title: The title of the song.
    ///   - action: The action to perform when the item is tapped.
    init(
        originalSectionTitle: String,
        number: String,
        title: String,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.originalSectionTitle = originalSectionTitle
        self.number = number
        self.title = title
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text("\(originalSectionTitle)")
                    .foregroundColor(.secondary)
                Text("\(number): \(title)")
            }
            .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    ExactMatchItem(originalSectionTitle: "Section", number: "1", title: "Title", action: {})
}
