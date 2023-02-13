import SwiftUI
import UIKit

@objc enum ThemeColor: Int {
    case light
    case dark
}

@objc class Theme: NSObject {
    
//    private static let themeColorKey = "ThemeColor"
//    @objc static var currentThemeColor: ThemeColor {
//        get {
//            return ThemeColor(rawValue: UserDefaults.standard.integer(forKey: themeColorKey)) ?? .light
//        }
//        set {
//            UserDefaults.standard.set(newValue.rawValue, forKey: themeColorKey)
//        }
//    }
//
//    @objc static let redColor = UIColor(r: 190, g: 25, b: 49, a: 255)
//    @objc static let coverColorOne = UIColor(r: 126, g: 25, b: 40, a: 255)
    @objc static let coverColorOne = UIColor(r: 190, g: 25, b: 49, a: 255)
    @objc static let coverColorTwo = UIColor(r: 124, g: 16, b: 32, a: 255)
//    @objc static var grayTrimColor: UIColor {
//        get {
//            switch currentThemeColor {
//            case .light:
//                return UIColor(r: 199, g: 199, b: 199, a: 255)
//            case .dark:
//                return UIColor(r: 70, g: 70, b: 70, a: 255)
//            }
//        }
//    }
//    @objc static var textColor: UIColor {
//        get {
//            switch currentThemeColor {
//            case .light:
//                return .black
//            case .dark:
//                return .white
//            }
//        }
//    }
//    @objc static var fadedTextColor: UIColor {
//        get {
//            switch currentThemeColor {
//            case .light:
//                return textColor.withAlphaComponent(0.5)
//            case .dark:
//                return textColor.withAlphaComponent(0.7)
//            }
//        }
//    }
//    @objc static var paperColor: UIColor {
//        get {
//            switch currentThemeColor {
//            case .light:
//                return .white
//            case .dark:
//                return .black
//            }
//        }
//    }
//
//    private static let lowVisionFontModeKey = "LowVisionFontMode" // true = low vision mode, false = standard mode
//    @objc static var isLowVisionFontModeActive: Bool {
//        get {
//            return UserDefaults.standard.bool(forKey: lowVisionFontModeKey)
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: lowVisionFontModeKey)
//        }
//    }
//
//    @objc static var normalFontName: String {
//        get {
//            if isLowVisionFontModeActive {
//                return "APHont"
//            } else {
//                return standardFontName
//            }
//        }
//    }
//
//    private static let standardFontNameKey = "StandardFontName"
//    @objc static var standardFontName: String {
//        get {
//            return UserDefaults.standard.string(forKey: standardFontNameKey) ?? "Charter-Roman"
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: standardFontNameKey)
//        }
//    }
//
//    private static let titleNumberFontNameKey = "TitleNumberFontName"
//    @objc static var titleNumberFontName: String {
//        get {
//            if isLowVisionFontModeActive {
//                return "APHont-Bold"
//            } else {
//                return UserDefaults.standard.string(forKey: titleNumberFontNameKey) ?? "Charter-Black"
//            }
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: titleNumberFontNameKey)
//        }
//    }
//
//    @objc static func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
//        return font(forTextStyle: textStyle, prescaled: true)
//    }
    
//    @objc static func font(forTextStyle textStyle: UIFont.TextStyle, prescaled: Bool = true) -> UIFont {
//        let defaultStyleSize: CGFloat
//        switch textStyle {
//        case .title1:
//            defaultStyleSize = 28
//        case .title2:
//            defaultStyleSize = 22
//        case .title3:
//            defaultStyleSize = 20
//        case .headline:
//            defaultStyleSize = 17
//        case .body:
//            defaultStyleSize = 17
//        case .callout:
//            defaultStyleSize = 16
//        case .subheadline:
//            defaultStyleSize = 15
//        case .footnote:
//            defaultStyleSize = 13
//        case .caption1:
//            defaultStyleSize = 12
//        case .caption2:
//            defaultStyleSize = 11
//        default:
//            defaultStyleSize = 17
//        }
//
//        let customFont: UIFont
//        switch textStyle {
//        case .headline:
//            customFont = UIFont.font(withDynamicName: Theme.titleNumberFontName, size: defaultStyleSize, numberSpacing: .mono)
//        default:
//            customFont = UIFont.font(withDynamicName: Theme.normalFontName, size: defaultStyleSize)
//        }
//
//        if prescaled {
//            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: customFont)
//        } else {
//            return customFont
//        }
//    }
    
//    @objc static func loadFontNamed(_ name: String, completion: (()->Void)?) {
//        let cfName = name as CFString
//        let cfDescriptors = [ CTFontDescriptorCreateWithNameAndSize(cfName, 50) ] as CFArray
//
//        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(cfDescriptors, nil) { (state, dictionary) -> Bool in
//            if state == .didFinish {
//                DispatchQueue.main.async {
//                    completion?()
//                }
//            }
//            return true
//        }
//    }
}

extension UIColor {
    convenience init(r: UInt, g: UInt, b: UInt, a: UInt) {
        let red = min(255, max(0, r))
        let green = min(255, max(0, g))
        let blue = min(255, max(0, b))
        let alpha = min(255, max(0, a))
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha)/255)
    }
}

extension Color {
    static let coverColorOne = Color(Theme.coverColorOne)
    static let coverColorTwo = Color(Theme.coverColorTwo)
}
