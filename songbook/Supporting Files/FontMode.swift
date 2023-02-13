import SwiftUI

enum FontMode: Int {
    case `default`
    case lowVision
    case custom

    func font(style: Font.TextStyle) -> Font {
        switch self {
        case .default:
            return style.font(named: "Charter-Roman")
        case .lowVision:
            return style.font(named: "APHont")
        case .custom:
            if let customFontName = UserDefaults.standard.string(forKey: "CustomFontName") {
                return style.font(named: customFontName)
            } else {
                return .system(style)
            }
        }
    }
}

extension Font.TextStyle {
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

    func font(named name: String) -> Font {
        Font.custom(name, size: defaultSize, relativeTo: self)
    }
}
