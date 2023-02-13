import BookModel
import SwiftUI
import Zip

@main
struct SongbookApp: App {

    @StateObject var bookModel = BookModel()

    init() {
        let clearAppearance = UIToolbarAppearance()
        clearAppearance.configureWithTransparentBackground()
        UIToolbar.appearance().compactScrollEdgeAppearance = clearAppearance
        UIToolbar.appearance().standardAppearance = clearAppearance
        UIToolbar.appearance().compactAppearance = clearAppearance
        UIToolbar.appearance().scrollEdgeAppearance = clearAppearance
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
