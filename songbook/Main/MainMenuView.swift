import BookModel
import SwiftUI

/// The toolbar menu for the main app screen.
@MainActor
struct MainMenuView: View {
    /// The currently selected appearance.
    @AppStorage(.StorageKey.colorTheme) var appearance: Appearance = .automatic

    /// The shared audio player.
    @Environment(AudioPlayer.self) var audioPlayer

    /// The book model.
    var bookModel: BookModel

    /// The index of the currently visible page.
    @AppStorage(.StorageKey.currentPageIndex) var currentPageIndex = 0

    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default

    /// The playable items for the current page.
    var playableItems: [PlayableItem] {
        bookModel.playableItemsForPageIndex[currentPageIndex] ?? []
    }

    /// `true` if the custom font picker is shown.
    @State var showFontPicker = false

    //let testSongs = ["0-0", "0-1"] // ["0-0", "0-376", "0-589"] // shortest:376 longest:589
    //@State var testSongIndex = 0

    var body: some View {
        Menu {
            ForEach(Array(playableItems.enumerated()), id: \.offset) { index, item in
                Button {
                    print("Play Tune \(index + 1)")
                    audioPlayer.play(item)
                } label: {
                    if playableItems.count > 1 {
                        Label("Play Tune \(index + 1)", systemImage: "play")
                    } else {
                        Label("Play Tune", systemImage: "play")
                    }
                }
            }
            Divider()
            if let bookURL = bookModel.shareBookURL {
                ShareLink(
                    item: bookURL,
                    subject: Text("\(bookURL.deletingPathExtension().lastPathComponent)")
                ) {
                    Label("Share Book", systemImage: "square.and.arrow.up")
                }
            }
            Menu {
                Picker("Appearance", selection: $appearance) {
                    Label("Light", systemImage: "sun.max")
                        .tag(Appearance.light)
                    Label("Dark", systemImage: "moon")
                        .tag(Appearance.dark)
                    Label("Automatic", systemImage: "circle.righthalf.filled")
                        .tag(Appearance.automatic)
                }
                Divider()
                Picker(
                    "Font",
                    selection: Binding(
                        get: {
                            fontMode
                        },
                        set: { mode in
                            switch mode {
                            case .custom:
                                showFontPicker = true
                            default:
                                fontMode = mode
                            }
                        }
                    )
                ) {
                    Label("Default Font", systemImage: "textformat")
                        .tag(FontMode.default)
                    Label("Low Vision Font", systemImage: "a.magnify"
                    ).tag(FontMode.lowVision)
                    if case .custom = fontMode {
                        Label("Custom Font", systemImage: "ellipsis.circle")
                            .tag(fontMode)
                    } else {
                        Label("Custom Font", systemImage: "ellipsis.circle")
                            .tag(FontMode.custom(name: ""))
                    }
                }
            } label: {
                Label("Appearance", systemImage: "textformat.size") // textformat.size eye paintpalette sun.max
            }
        } label: {
            Label("Menu", systemImage: "ellipsis.circle")
        }
        .menuOrder(.fixed)
        .sheet(isPresented: $showFontPicker) {
            FontScreen()
                .tint(.accentColor)
        }
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(bookModel: BookModel())
    }
}
