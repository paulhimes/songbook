import BookModel
import SwiftUI
import CoreData

struct MainView: View {
    /// The book model.
    @ObservedObject var bookModel: BookModel

    /// The currently selected appearance.
    @AppStorage(.StorageKey.colorTheme) var appearance: Appearance = .automatic

    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default
    @AppStorage(.StorageKey.customFontName) var customFontName: String?

    @State var showFontPicker = false

    /// The tint color of the bottom toolbar controls.
    @State var tint: Color = .white

    var body: some View {
        ZStack {
            if let book = bookModel.book {
                BookView(book: book, tint: $tint)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button {
                                print("Search")
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            Spacer()
                            Menu {
                                Button {
                                    print("Play Tune")
                                } label: {
                                    Label("Play Tune", systemImage: "play")
                                }
                                if bookModel.bookWithTunesURL != nil {
                                    Menu {
                                        ShareLink(item: bookModel.bookWithTunesURL!) {
                                            Label("With Tunes", systemImage: "music.note")
                                        }
                                        ShareLink(item: bookModel.bookWithoutTunesURL!) {
                                            Label("Without Tunes", systemImage: "nosign")
                                        }
                                    } label: {
                                        Label("Share Book", systemImage: "square.and.arrow.up")
                                    }
                                } else {
                                    ShareLink(item: bookModel.bookWithoutTunesURL!) {
                                        Label("Share Book", systemImage: "square.and.arrow.up")
                                    }
                                }
                                Menu {
                                    Picker("Appearance", selection: $appearance) {
                                        Label("Light", systemImage: "sun.max").tag(Appearance.light)
                                        Label("Dark", systemImage: "moon").tag(Appearance.dark)
                                        Label("Automatic", systemImage: "circle.righthalf.filled").tag(Appearance.automatic)
                                    }
                                    Divider()
                                    Picker("Font", selection: .init(get: {
                                        fontMode
                                    }, set: { mode in
                                        fontMode = mode
                                        if fontMode == .custom {
                                            showFontPicker = true
                                        }
                                    })) {
                                        Label("Default Font", systemImage: "textformat").tag(FontMode.default)
                                        Label("Low Vision Font", systemImage: "a.magnify").tag(FontMode.lowVision)
                                        Label("Custom Font", systemImage: "ellipsis.circle").tag(FontMode.custom)
                                    }
                                } label: {
                                    Label("Appearance", systemImage: "textformat.size") // textformat.size eye paintpalette sun.max
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                            .menuOrder(.fixed)
                        }
                    }
                    .ignoresSafeArea()
                    .tint(tint)
            } else {
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
        .sheet(isPresented: $showFontPicker) {
            NavigationStack {
                FontPicker(fontName: $customFontName)
                    .navigationTitle("Custom Font")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        Button("Cancel", role: .cancel) {
                            showFontPicker = false
                        }
                    }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(bookModel: BookModel())
    }
}
