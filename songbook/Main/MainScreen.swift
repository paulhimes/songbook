import BookModel
import SwiftUI
import CoreData

/// The main top-level screen of the app.
@MainActor
struct MainScreen: View {
    /// The currently selected appearance.
    @AppStorage(.StorageKey.colorTheme) var appearance: Appearance = .automatic

    /// The shared audio player.
    @Environment(AudioPlayer.self) var audioPlayer

    /// The book model.
    var bookModel: BookModel

    /// The index of the currently visible page.
    @AppStorage(.StorageKey.currentPageIndex) var currentPageIndex = 0

    /// `true` iff the search UI is visible.
    @State var isSearching = false

    /// The tint color of the bottom toolbar controls.
    var tint: Color {
        guard bookModel.pageModels.count > currentPageIndex else { return .white }
        if case .book = bookModel.pageModels[currentPageIndex] {
            return .white
        } else {
            return .accentColor
        }
    }

    var body: some View {
        ZStack {
            if !bookModel.pageModels.isEmpty {
                // Show the book.
                NavigationStack {
                    BookScreen(pages: bookModel.pageModels)
                        .ignoresSafeArea()
                        .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                Button {
                                    print("Search")
                                    isSearching = true
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
                                MainMenuView(bookModel: bookModel)
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
        .fullScreenCover(isPresented: $isSearching, content: {
            SearchScreen(bookModel: bookModel, searchPresented: $isSearching)
        })
        .statusBarHidden(true)
        .preferredColorScheme(appearance.colorScheme)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(bookModel: BookModel())
    }
}
