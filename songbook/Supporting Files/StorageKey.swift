import SwiftUI

extension String {
    /// Key names for user defaults / AppStorage.
    enum StorageKey {
        /// The app color theme.
        static let colorTheme = "ColorTheme"
        /// The app font mode.
        static let fontMode = "FontMode"
        /// The audio playback mode.
        static let playbackMode = "PlaybackMode"
    }
}
