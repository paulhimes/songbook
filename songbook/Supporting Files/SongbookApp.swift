import BookModel
import SwiftUI
import Zip

@main
struct SongbookApp: App {

    /// The shared audio player of the app.
    let audioPlayer = AudioPlayer()

    /// The data model of the currently loaded book.
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
            MainScreen(bookModel: bookModel)
                .onOpenURL { url in
                    print("App was asked to open file at \(url)")
                    bookModel.importBook(from: url)
                }
                .onAppear {
                    print("\(URL.bookDirectory)")
                }
                .environmentObject(audioPlayer)
                .environmentObject(audioPlayer.progress)
        }
    }
}
