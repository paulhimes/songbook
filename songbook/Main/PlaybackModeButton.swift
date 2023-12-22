import SwiftUI

/// A button to show the status of and modify the playback mode setting.
struct PlaybackModeButton: View {

    /// The playback mode setting.
    @AppStorage(.StorageKey.playbackMode) var playbackMode: PlaybackMode = .single
    
    /// The button's accessibility hint.
    var accessibilityHint: String {
        switch playbackMode {
        case .single:
            "Tap to Play All"
        case .continuous:
            "Tap to Shuffle"
        case .shuffle:
            "Tap to Repeat"
        case .repeatOne:
            "Tap to Play Once"
        }
    }

    /// The system image name of the button's image.
    var imageName: String {
        switch playbackMode {
        case .single:
            "repeat"
        case .continuous:
            "repeat"
        case .shuffle:
            "shuffle"
        case .repeatOne:
            "repeat.1"
        }
    }

    /// The title of the button.
    var title: String {
        switch playbackMode {
        case .single:
            "Play One"
        case .continuous:
            "Play All"
        case .shuffle:
            "Shuffle"
        case .repeatOne:
            "Repeat"
        }
    }

    var body: some View {
        Button(title, systemImage: imageName) {
            switch playbackMode {
            case .single:
                playbackMode = .continuous
                print("Playback Mode: Continuous")
            case .continuous:
                playbackMode = .shuffle
                print("Playback Mode: Shuffle")
            case .shuffle:
                playbackMode = .repeatOne
                print("Playback Mode: Repeat One")
            case .repeatOne:
                playbackMode = .single
                print("Playback Mode: Single")
            }
        }
        .tint(.accentColor.opacity(playbackMode == .single ? 0.5 : 1.0))
        .accessibilityHint(accessibilityHint)
    }
}

struct PlaybackModeButton_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackModeButton()
    }
}
