import SwiftUI

struct PreviewView: View {

    let title: String
    var image: UIImage {
        let path = Bundle.main.path(forResource: "Icon", ofType: "png")!
        return UIImage(contentsOfFile: path)!
    }
    var instructions: Text {
        Text("To open, tap the action button \(Image(systemName: "square.and.arrow.up")) below.\nThen tap the Songbook app \(Image(systemName: "app")).")
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Image(uiImage: image)
                .resizable()
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .minimumScaleFactor(0.5)
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

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(title: "Songs & Hymns of Believers (v6)")
    }
}
