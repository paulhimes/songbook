import SwiftUI

/// A button to show the status of and modify the playback mode setting.
struct PlaybackModeButton: View {

    /// The playback mode setting.
    @AppStorage(.StorageKey.playbackMode) var playbackMode: PlaybackMode = .single

    var body: some View {
        Button {
            print("Playback Mode")
            switch playbackMode {
            case .single:
                playbackMode = .continuous
            case .continuous:
                playbackMode = .repeatOne
            case .repeatOne:
                playbackMode = .single
            }
        } label: {
            switch playbackMode {
            case .single:
                Label("Play One", systemImage: "repeat")
                    .opacity(0.3)
                    .accessibilityHint("Tap to Play All")
            case .continuous:
                Label("Play All", systemImage: "repeat")
                    .accessibilityHint("Tap to Repeat")
            case .repeatOne:
                Label("Repeat", systemImage: "repeat.1")
                    .accessibilityHint("Tap to Play One")
            }
        }
    }
}

struct PlaybackModeButton_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackModeButton()
    }
}
