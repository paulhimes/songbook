import SwiftUI

/// A font mode. Either a pre-determined font or a custom font.
enum FontMode {
    /// The default app font: Charter
    case `default`
    /// The low-vision app font: APHont
    case lowVision
    /// A custom font selection including the name of the custom font.
    case custom(name: String)

    /// Build a `Font` based on the mode.
    /// - Parameter style: The style/context where the font will be used.
    /// - Returns: The resolved `Font`.
    func font(style: Font.TextStyle) -> Font {
        switch self {
        case .default:
            return style.font(named: "Charter-Roman")
        case .lowVision:
            return style.font(named: "APHont")
        case .custom(let name):
            return style.font(named: name)
        }
    }
}

extension FontMode: RawRepresentable {
    var rawValue: String {
        switch self {
        case .default:
            return "FontMode.default"
        case .lowVision:
            return "FontMode.lowVision"
        case .custom(let name):
            return name
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "FontMode.default":
            self = .default
        case "FontMode.lowVision":
            self = .lowVision
        default:
            self = .custom(name: rawValue)
        }
    }
}

extension FontMode: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension Font.TextStyle {
    /// The default point size for this style.
    var defaultSize: CGFloat {
        switch self {
        case .body:
            return 17
        case .callout:
            return 16
        case .caption:
            return 12
        case .caption2:
            return 11
        case .footnote:
            return 13
        case .headline:
            return 17
        case .largeTitle:
            return 34
        case .subheadline:
            return 15
        case .title:
            return 28
        case .title2:
            return 22
        case .title3:
            return 20
        @unknown default:
            return Font.TextStyle.body.defaultSize
        }
    }

    /// A font of the given name at the default point size for this style.
    /// - Parameter name: The name of the font.
    /// - Returns: The resolved `Font`.
    func font(named name: String) -> Font {
        Font.custom(name, size: defaultSize, relativeTo: self)
    }
}
