import SwiftUI

/// Shows a song page.
struct SongPageView: View {

    // Combines the song's `number` and `title`.
    let combinedTitle: String

    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default

    /// The text of the song.
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(fontMode.font(style: .body))
                .padding()
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    SongPageView(combinedTitle: "Title", text: "Text")
}
