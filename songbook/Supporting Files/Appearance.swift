import SwiftUI

/// A UI appearance.
enum Appearance: Int {
    /// Light background. Dark content.
    case light
    /// Dark background. Light content.
    case dark
    /// Automatically follow the OS system state.
    case automatic

    /// The corresponding `ColorScheme` for this `Appearance`.
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .automatic:
            return nil
        }
    }
}
