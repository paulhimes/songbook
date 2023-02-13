import SwiftUI

enum Appearance: Int {
    case light
    case dark
    case automatic

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
