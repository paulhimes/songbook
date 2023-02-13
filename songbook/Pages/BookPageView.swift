import SwiftUI

struct BookPageView: View {

    let title: String
    let version: Int

    var body: some View {
        ZStack {
            RedGradientView()
            VerticalProportionLayout(ratio: 1 / .phi) {
                BookPageContent(title: title, version: version)
            }
        }
    }
}

struct BookPageContent: View {
    let title: String
    let version: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle)
                .minimumScaleFactor(0.5)
            Text("Version \(version)")
                .font(.subheadline)
                .opacity(0.7)
                .minimumScaleFactor(0.5)
        }
        .padding()
        .foregroundColor(.white)
        .multilineTextAlignment(.leading)
    }
}

struct BookPageView_Previews: PreviewProvider {
    static var previews: some View {
        BookPageView(title: "Title and a long number of words that will have to wrap and wrap some more until it takes up a large number of lines that will exceed the bounds of the container view", version: 1)
    }
}
