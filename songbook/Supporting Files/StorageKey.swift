import BookModel
import SwiftUI

extension String {
    /// Key names for user defaults / AppStorage.
    enum StorageKey {
        /// The app color theme.
        static let colorTheme = "ColorTheme"
        /// The index of the currently visible page.
        static let currentPageIndex = "CurrentPageIndex"
        /// The id of the most recently played item.
        static let currentPlayableItemId = "CurrentPlayableItemId"
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

    var currentPlayableItemId: PlayableItemId? {
        get {
            guard let string = string(forKey: .StorageKey.currentPlayableItemId) else { return nil }
            return PlayableItemId(string)
        }
        set {
            set(newValue?.description, forKey: .StorageKey.currentPlayableItemId)
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
