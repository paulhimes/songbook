import SwiftUI

struct RedGradientView: View {
    var body: some View {
        LinearGradient(
            colors: [.coverColorOne, .coverColorTwo],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct RedGradientView_Previews: PreviewProvider {
    static var previews: some View {
        RedGradientView()
    }
}
