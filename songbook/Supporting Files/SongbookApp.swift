import BookModel
import SwiftUI
import Zip

@main
struct SongbookApp: App {

    /// The container for services used throughout the app.
    @StateObject var serviceContainer = ServiceContainer()

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
            MainScreen(bookModel: serviceContainer.bookModel)
                .onOpenURL { url in
                    print("App was asked to open file at \(url)")
                    UserDefaults.standard.currentPageIndex = 0
                    UserDefaults.standard.currentPlayableItemId = nil
                    Task {
                        await serviceContainer.bookModel.importBook(from: url)
                    }
                }
                .onAppear {
                    print("\(URL.bookDirectory)")
                }
                .environmentObject(serviceContainer.audioPlayer)
                .environmentObject(serviceContainer.audioPlayer.progress)
        }
    }
}
