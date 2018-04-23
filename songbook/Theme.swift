//
//  Theme.swift
//  songbook
//
//  Created by Paul Himes on 4/12/18.
//  Copyright © 2018 Paul Himes. All rights reserved.
//

import UIKit

@objc enum ThemeColor: Int {
    case light
    case dark
}

@objc class Theme: NSObject {
    @objc static let defaultPairs: [String: String] = ["Marion": "Marion-Bold",
                                                 "Iowan Old Style": "IowanOldStyle-Black",
//                                                 "Baskerville": "Baskerville-Bold",
//                                                 "BodoniSvtyTwoITCTT-Book": "BodoniSvtyTwoITCTT-Bold",
                                                 "BookmanOldStyle": "BookmanOldStyle-Bold",
                                                 "Charter-Roman": "Charter-Black",
//                                                 "Cochin": "Cochin-Bold",
//                                                 "HiraMinProN-W3": "HiraMinProN-W6",
                                                 "Palatino-Roman": "Palatino-Bold",
//                                                 "TimesNewRomanPSMT": "TimesNewRomanPS-BoldMT"
    ]
    
    @objc static let normalFontNames = ["Marion",
                              "Iowan Old Style",
//                              "Baskerville",
//                              "BodoniSvtyTwoITCTT-Book",
                              "BookmanOldStyle",
                              "Charter-Roman",
//                              "Cochin",
//                              "HiraMinProN-W3",
                              "Palatino-Roman",
//                              "TimesNewRomanPSMT"
    ]
    
    @objc static let titleNumberFontNames = ["Marion-Bold",
                                   "IowanOldStyle-Black",
//                                   "Baskerville-Bold",
//                                   "Baskerville-SemiBold",
//                                   "BodoniSvtyTwoITCTT-Bold",
                                   "BookmanOldStyle-Bold",
                                   "Charter-Black",
//                                   "Charter-Bold",
//                                   "Cochin-Bold",
//                                   "HiraMinProN-W6",
//                                   "Optima-Bold",
//                                   "Optima-ExtraBlack",
                                   "Palatino-Bold",
//                                   "TimesNewRomanPS-BoldMT"
    ]
    
    private static let themeColorKey = "ThemeColor"
    @objc static var currentThemeColor: ThemeColor {
        get {
            return ThemeColor(rawValue: UserDefaults.standard.integer(forKey: themeColorKey)) ?? .light
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeColorKey)
        }
    }
    
    @objc static let redColor = UIColor(r: 190, g: 25, b: 49, a: 255)
    @objc static let coverColorOne = UIColor(r: 126, g: 25, b: 40, a: 255)
    @objc static let coverColorTwo = UIColor(r: 124, g: 16, b: 32, a: 255)
    @objc static var grayTrimColor: UIColor {
        get {
            switch currentThemeColor {
            case .light:
                return UIColor(r: 199, g: 199, b: 199, a: 255)
            case .dark:
                return UIColor(r: 70, g: 70, b: 70, a: 255)
            }
        }
    }
    @objc static var textColor: UIColor {
        get {
            switch currentThemeColor {
            case .light:
                return .black
            case .dark:
                return .white
            }
        }
    }
    @objc static var fadedTextColor: UIColor {
        get {
            switch currentThemeColor {
            case .light:
                return textColor.withAlphaComponent(0.5)
            case .dark:
                return textColor.withAlphaComponent(0.7)
            }
        }
    }
    @objc static var paperColor: UIColor {
        get {
            switch currentThemeColor {
            case .light:
                return .white
            case .dark:
                return .black
            }
        }
    }
    
    private static let normalFontNameKey = "NormalFontName"
    @objc static var normalFontName: String {
        get {
            return UserDefaults.standard.string(forKey: normalFontNameKey) ?? "Charter-Roman"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: normalFontNameKey)
        }
    }
    
    private static let titleNumberFontNameKey = "TitleNumberFontName"
    @objc static var titleNumberFontName: String {
        get {
            return UserDefaults.standard.string(forKey: titleNumberFontNameKey) ?? "Charter-Black"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: titleNumberFontNameKey)
        }
    }
    
    @objc static func loadFontNamed(_ name: String, completion: (()->Void)?) {
        let cfName = name as CFString
        let cfDescriptors = [ CTFontDescriptorCreateWithNameAndSize(cfName, 50) ] as CFArray
        
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(cfDescriptors, nil) { (state, dictionary) -> Bool in
            if state == .didFinish {
                DispatchQueue.main.async {
                    completion?()
                }
            }
            return true
        }
    }
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
