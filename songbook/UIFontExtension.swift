//
//  UIFontExtension.swift
//  songbook
//
//  Created by Paul Himes on 4/15/18.
//  Copyright © 2018 Paul Himes. All rights reserved.
//

extension UIFont {
    static func font(withDynamicName name: String, size: CGFloat) -> UIFont {
        return UIFont(descriptor: UIFontDescriptor(name: name, size: size), size: size)
    }
}
