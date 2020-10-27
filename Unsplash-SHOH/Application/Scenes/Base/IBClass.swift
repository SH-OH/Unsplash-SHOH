//
//  IBClass.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/28.
//

import UIKit

@IBDesignable
class IBSearchBar: UISearchBar {
    @IBInspectable var textColor: UIColor {
        get {
            return findSearchTextField()?.textColor ?? .black
        }
        set {
            if let textField = self.value(forKey: "searchField") as? UITextField {
                textField.textColor = newValue
            }
        }
    }
    
    private func findSearchTextField() -> UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        }
        if let textField = self.value(forKey: "searchField") as? UITextField {
            return textField
        }
        return nil
    }
}
