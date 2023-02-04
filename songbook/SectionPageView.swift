import SwiftUI

struct SectionPageView: View {

    let title: String

    var body: some View {
        ZStack(alignment: .leading) {
            Color.white.ignoresSafeArea()
            Text(title)
                .padding()
                .multilineTextAlignment(.leading)
                .foregroundColor(.black)
        }
    }
}

struct SectionPageView_Previews: PreviewProvider {
    static var previews: some View {
        SectionPageView(title: "Title")
    }
}
