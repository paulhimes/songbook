import SwiftUI

struct SectionPageView: View {

    let title: String

    var body: some View {
        ZStack {
            VerticalProportionLayout(ratio: 1 / .phi) {
                Text(title)
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
            }
            .background(.white)
        }
    }
}

struct SectionPageView_Previews: PreviewProvider {
    static var previews: some View {
        SectionPageView(title: "Title")
    }
}
