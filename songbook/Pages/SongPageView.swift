import SwiftUI

struct SongPageView: View {
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default
    @AppStorage(.StorageKey.customFontName) var customFontName: String?
    let title: String

    var body: some View {
        Text(title)
            .font(fontMode.font(style: .body, customFontName: customFontName))
            .padding()
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

    }
}

struct SongPageView_Previews: PreviewProvider {
    static var previews: some View {
        SongPageView(title: "Title")
    }
}
