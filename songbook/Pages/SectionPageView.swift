import SwiftUI

/// Shows a section title page.
struct SectionPageView: View {
    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default

    /// The title of the section.
    let title: String

    var body: some View {
        VerticalRatioLayout(ratio: 1 / .phi) {
            Text(title)
                .font(fontMode.font(style: .title))
                .padding()
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            Color.clear
                .frame(height: 0)
                .background(Material.ultraThinMaterial)
        }
    }
}

struct SectionPageView_Previews: PreviewProvider {
    static var previews: some View {
        SectionPageView(title: "Title")
    }
}
