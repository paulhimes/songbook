import SwiftUI

/// The view for a search item with a song title and optional number.
struct PlainItemView: View {
    
    /// The action to perform when the item is tapped.
    let action: () -> Void

    /// The number of the song.
    let number: String?

    /// The title of the song.
    let title: String
    
    /// Initializes a ``PlainItemView``.
    /// - Parameters:
    ///   - number: Optionally, the number of the song.
    ///   - title: The title of the song.
    ///   - action: The action to perform when the item is tapped.
    init(number: String?, title: String, action: @escaping () -> Void) {
        self.action = action
        self.number = number
        self.title = title
    }

    var body: some View {
        Button("\(number ?? ""): \(title)", action: action)
    }
}

#Preview {
    PlainItemView(number: "1", title: "Title", action: {})
}
