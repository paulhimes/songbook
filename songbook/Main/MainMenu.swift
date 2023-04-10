import BookModel
import SwiftUI

/// The toolbar menu for the main app screen.
struct MainMenu: View {
    /// The currently selected appearance.
    @AppStorage(.StorageKey.colorTheme) var appearance: Appearance = .automatic

    /// The shared audio player.
    @EnvironmentObject var audioPlayer: AudioPlayer

    /// The book model.
    @ObservedObject var bookModel: BookModel

    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default

    /// `true` if the custom font picker is shown.
    @State var showFontPicker = false

    let testSongs = ["0-0", "0-376", "0-589"] // shortest:376 longest:589
    @State var testSongIndex = 0

    var body: some View {
        Menu {
            Button {
                print("Play Tune")
                if let item = bookModel.index?.playableItems.first(where: { $0.audioFileURL.absoluteString.contains(testSongs[testSongIndex]) }) {
                    audioPlayer.play(item: item)
                }
                testSongIndex = (testSongIndex + 1) % 3
            } label: {
                Label("Play Tune", systemImage: "play")
            }
            if let bookWithTunesURL = bookModel.bookWithTunesURL {
                Menu {
                    ShareLink(item: bookWithTunesURL) {
                        Label("With Tunes", systemImage: "music.note")
                    }
                    if let bookWithoutTunesURL = bookModel.bookWithoutTunesURL {
                        ShareLink(item: bookWithoutTunesURL) {
                            Label("Without Tunes", systemImage: "nosign")
                        }
                    }
                } label: {
                    Label("Share Book", systemImage: "square.and.arrow.up")
                }
            } else {
                if let bookWithoutTunesURL = bookModel.bookWithoutTunesURL {
                    ShareLink(item: bookWithoutTunesURL) {
                        Label("Share Book", systemImage: "square.and.arrow.up")
                    }
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
        MainMenu(bookModel: BookModel())
    }
}
