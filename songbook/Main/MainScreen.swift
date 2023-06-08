import BookModel
import SwiftUI
import CoreData

/// The main top-level screen of the app.
struct MainScreen: View {
    /// The currently selected appearance.
    @AppStorage(.StorageKey.colorTheme) var appearance: Appearance = .automatic

    /// The shared audio player.
    @EnvironmentObject var audioPlayer: AudioPlayer

    /// The index of the currently visible page.
    @AppStorage(.StorageKey.currentPageIndex) var currentPageIndex = 0

    /// The book model.
    @ObservedObject var bookModel: BookModel

    /// The tint color of the bottom toolbar controls.
    var tint: Color {
        guard let bookIndex = bookModel.index else { return .white }
        if case .book = bookIndex.pageModels[currentPageIndex] {
            return .white
        } else {
            return .accentColor
        }
    }

    var body: some View {
        ZStack {
            if let bookIndex = bookModel.index {
                // Show the book.
                NavigationStack {
                    BookScreen(pages: bookIndex.pageModels)
                        .ignoresSafeArea()
                        .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                Button {
                                    print("Search")
                                } label: {
                                    Label("Search", systemImage: "magnifyingglass")
                                }
                                .frame(minWidth: 44, minHeight: 44)
                                Spacer()
                                if audioPlayer.isPlaying {
                                    Button {
                                        print("Stop")
                                        audioPlayer.stop()
                                    } label: {
                                        Label("Stop", systemImage: "stop.fill")
                                    }
                                    .frame(minWidth: 44, minHeight: 44)
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
                .animation(.easeInOut, value: tint)
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
