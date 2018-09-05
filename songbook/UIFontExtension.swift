//
//  UIFontExtension.swift
//  songbook
//
//  Created by Paul Himes on 4/15/18.
//

@objc enum NumberSpacing: Int {
    case mono
    case proportional
}

extension UIFont {
    @objc static func font(withDynamicName name: String, size: CGFloat) -> UIFont {
        return UIFont(descriptor: UIFontDescriptor(name: name, size: size), size: size)
    }
    
    @objc static func font(withDynamicName name: String, size: CGFloat, numberSpacing: NumberSpacing) -> UIFont {
        let type: Int
        switch numberSpacing {
        case .mono:
            type = kMonospacedNumbersSelector
        case .proportional:
            type = kProportionalNumbersSelector
        }
        
        let numberSpacedDescriptor = UIFontDescriptor(name: name, size: size).addingAttributes([UIFontDescriptor.AttributeName.featureSettings: [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType, UIFontDescriptor.FeatureKey.typeIdentifier: type]]])

        return UIFont(descriptor: numberSpacedDescriptor, size: size)
    }
}
