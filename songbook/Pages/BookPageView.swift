import SwiftUI

/// Shows a book title page.
struct BookPageView: View {
    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default

    /// The title of the book.
    let title: String

    /// The version number of the book.
    let version: Int

    var body: some View {
        VerticalRatioLayout(ratio: 1 / .phi) {
            RedGradientView()
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .minimumScaleFactor(0.5)
                    .font(fontMode.font(style: .largeTitle))
                Text("Version \(version)")
                    .opacity(0.7)
                    .minimumScaleFactor(0.5)
                    .font(fontMode.font(style: .subheadline))
            }
            .padding()
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
        }
    }
}

struct BookPageView_Previews: PreviewProvider {
    static var previews: some View {
        BookPageView(title: "Title and a long number of words that will have to wrap and wrap some more until it takes up a large number of lines that will exceed the bounds of the container view", version: 1)
    }
}
