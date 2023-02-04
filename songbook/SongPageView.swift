import SwiftUI

struct SongPageView: View {

    let title: String

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text(title)
                .foregroundColor(.black)
        }
    }
}

struct SongPageView_Previews: PreviewProvider {
    static var previews: some View {
        SongPageView(title: "Title")
    }
}
