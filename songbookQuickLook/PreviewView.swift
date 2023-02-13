import SwiftUI

struct PreviewView: View {

    /// Action button icon.
    let actionImage = Image(systemName: "square.and.arrow.up")

    /// App icon.
    let appImage = Image(systemName: "app")

    /// The background gradient image.
    var backgroundImage: UIImage {
        let path = Bundle.main.path(forResource: "Icon", ofType: "png")!
        return UIImage(contentsOfFile: path)!
    }
    var instructions: Text {
        Text(
            "To open, tap the action button \(actionImage).\nThen tap the Songbook app \(appImage)."
        )
    }

    /// The name of the file.
    let title: String

    var body: some View {
        ZStack(alignment: .leading) {
            Image(uiImage: backgroundImage)
                .resizable()
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .minimumScaleFactor(0.1)
                instructions
                    .font(.body)
                    .minimumScaleFactor(0.1)
                    .layoutPriority(1)
            }
            .padding()
        }
        .aspectRatio(1, contentMode: .fit)
        .foregroundColor(.white)
        .multilineTextAlignment(.leading)
    }
}

/// To enable previewing, temporarily add this file to the main app target.
struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(title: "The File Name with Tunes (v6)")
    }
}
