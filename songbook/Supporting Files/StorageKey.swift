import BookModel
import SwiftUI

extension String {
    /// Key names for user defaults / AppStorage.
    enum StorageKey {
        /// The app color theme.
        static let colorTheme = "ColorTheme"
        /// The index of the currently visible page.
        static let currentPageIndex = "CurrentPageIndex"
        /// The id of the most recently viewed song.
        static let currentSongId = "CurrentSongId"
        /// The app font mode.
        static let fontMode = "FontMode"
        /// The audio playback mode.
        static let playbackMode = "PlaybackMode"
    }
}

extension UserDefaults {
    var currentPageIndex: Int {
        get {
            integer(forKey: .StorageKey.currentPageIndex)
        }
        set {
            set(newValue, forKey: .StorageKey.currentPageIndex)
        }
    }

    var currentSongId: SongId? {
        get {
            guard let string = string(forKey: .StorageKey.currentSongId) else { return nil }
            return SongId(string)
        }
        set {
            set(newValue?.description, forKey: .StorageKey.currentSongId)
        }
    }

    var playbackMode: PlaybackMode {
        get {
            PlaybackMode(rawValue: integer(forKey: .StorageKey.playbackMode))
        }
        set {
            set(newValue.rawValue, forKey: .StorageKey.playbackMode)
        }
    }
}
