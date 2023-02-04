import SwiftUI

struct BookPageView: View {

    let title: String
    let version: String

    var body: some View {
        ZStack(alignment: .leading) {
            RedGradientView()
            VStack(alignment: .leading) {
                Text(title)
                Text("Version \(version)")
                    .opacity(0.5)
            }
            .padding()
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
        }
    }
}

struct BookPageView_Previews: PreviewProvider {
    static var previews: some View {
        BookPageView(title: "Title", version: "1")
    }
}
