//
//  UIColor+Extensions.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import UIKit.UIColor

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension BaseViewController {
    static func storyboard() -> Self {
        let name = self.reuseIdentifier
        let storyboard = UIStoryboard(name: name, bundle: .main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: name) as? Self else {
            preconditionFailure("Storyboard : '\(name)' init 실패")
        }
        return vc
    }
}
