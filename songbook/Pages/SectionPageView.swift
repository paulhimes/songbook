import SwiftUI

struct SectionPageView: View {
    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default
    @AppStorage(.StorageKey.customFontName) var customFontName: String?

    let title: String

    var body: some View {
        VerticalRatioLayout(ratio: 1 / .phi) {
            Text(title)
                .font(fontMode.font(style: .title, customFontName: customFontName))
                .padding()
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
        }
    }
}

struct SectionPageView_Previews: PreviewProvider {
    static var previews: some View {
        SectionPageView(title: "Title")
    }
}
