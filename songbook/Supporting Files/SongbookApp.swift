import BookModel
import SwiftUI
import Zip

@main
struct SongbookApp: App {

    @StateObject var bookModel = BookModel()

    init() {
//        let buttonAppearance = UIBarButtonItemAppearance()
//        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
//        buttonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.black]
//        buttonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.black]
//        buttonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.black]

        let coloredAppearance = UIToolbarAppearance()
        coloredAppearance.configureWithTransparentBackground()
//        coloredAppearance.buttonAppearance = buttonAppearance

        UIToolbar.appearance().compactScrollEdgeAppearance = coloredAppearance
        UIToolbar.appearance().standardAppearance = coloredAppearance
        UIToolbar.appearance().compactAppearance = coloredAppearance
        UIToolbar.appearance().scrollEdgeAppearance = coloredAppearance
        //        UIToolbar.appearance().barTintColor = .blue
        //        UIToolbar.appearance().tintColor = .green
        //        UIToolbar.appearance().backgroundColor = .orange

//        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.green], for: .normal)
//        UIBarButtonItem.appearance().tintColor = .orange
    }

    var body: some Scene {
        WindowGroup {
            MainView(bookModel: bookModel)
                .onOpenURL { url in
                    print("App was asked to open file at \(url)")
                    bookModel.importBook(from: url)
                }
                .onAppear {
                    print("\(URL.bookDirectory)")
                }
        }
    }
}
