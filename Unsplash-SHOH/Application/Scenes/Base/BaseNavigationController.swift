//
//  BaseNavigationController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UINavigationController

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
    }
    
    private func setupProperties() {
        setNavigationBarHidden(true, animated: false)
    }
}
