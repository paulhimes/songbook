import BookModel
import SwiftUI
import CoreData

/// The main top-level screen of the app.
struct MainScreen: View {
    /// The currently selected appearance.
    @AppStorage(.StorageKey.colorTheme) var appearance: Appearance = .automatic

    /// The shared audio player.
    @EnvironmentObject var audioPlayer: AudioPlayer

    /// The book model.
    @ObservedObject var bookModel: BookModel

    /// The tint color of the bottom toolbar controls.
    @State var tint: Color = .white

    var body: some View {
        ZStack {
            if let bookIndex = bookModel.index {
                // Show the book.
                NavigationStack {
                    BookScreen(pages: bookIndex.pageModels, tint: $tint)
                        .ignoresSafeArea()
                        .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                Button {
                                    print("Search")
                                } label: {
                                    Label("Search", systemImage: "magnifyingglass")
                                }
                                Spacer()
                                if audioPlayer.isPlaying {
                                    Button {
                                        print("Stop")
                                        audioPlayer.stop()
                                    } label: {
                                        Label("Stop", systemImage: "stop.fill")
                                    }
                                    Spacer()
                                    PlaybackModeButton()
                                }
                                MainMenu(bookModel: bookModel)
                            }
                        }
                        .safeAreaInset(edge: .bottom, alignment: .leading) {
                            ProgressBar()
                                .ignoresSafeArea()
                        }
                }
                .tint(tint)
            } else {
                // Show the loading screen.
                RedGradientView()
                VStack {
                    Text("Opening Book")
                        .foregroundColor(.white)
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(.circular)
                }
            }
        }
        .statusBarHidden(true)
        .preferredColorScheme(appearance.colorScheme)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(bookModel: BookModel())
    }
}
