//
//  BaseViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UIViewController

class BaseViewController: UIViewController {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    deinit {
        print("[👋deinit]\(String(describing: self))")
    }
    
}
