import BookModel
import SwiftUI

/// The toolbar menu for the main app screen.
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

    /// The playback mode setting.
    @AppStorage(.StorageKey.playbackMode) var playbackMode: PlaybackMode = .single

    /// `true` if the custom font picker is shown.
    @State var showFontPicker = false

    // let testSongs = ["0-0", "0-1"] // ["0-0", "0-376", "0-589"] // shortest:376 longest:589
    // @State var testSongIndex = 0

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
            Menu {
                Picker("Play Mode", selection: $playbackMode) {
                    playbackModeLabel(.single)
                    playbackModeLabel(.continuous)
                    playbackModeLabel(.shuffle)
                    playbackModeLabel(.repeatOne)
                }
            } label: {
                playbackModeLabel(playbackMode)
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
            Label("Menu", systemImage: "ellipsis")
        }
        .menuOrder(.fixed)
        .sheet(isPresented: $showFontPicker) {
            FontScreen()
        }
    }
    
    /// Builds a menu item label for a playback mode.
    ///
    /// - Parameter mode: The playback mode.
    /// - Returns: The menu item label.
    ///
    @ViewBuilder func playbackModeLabel(_ mode: PlaybackMode) -> some View {
        Label(mode.displayName, systemImage: mode.imageName)
            .tag(mode)
    }
}

#Preview {
    MainMenuView(bookModel: BookModel())
        .environment(AudioPlayer())
}
