import SwiftUI

/// Shows a song page.
struct SongPageView: View {
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
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            Color.clear
                .frame(height: 0)
                .background(Material.ultraThinMaterial)
        }
    }
}

struct SongPageView_Previews: PreviewProvider {
    static var previews: some View {
        SongPageView(text: "Text")
    }
}
