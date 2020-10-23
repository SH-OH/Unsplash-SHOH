//
//  AppLaunch.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit.UIWindow

struct AppLaunch {
    static func launchByOS(_ window: UIWindow?,
                           isScene: Bool) {
        if #available(iOS 13.0, *) {
            guard isScene else { return }
        }
        window?.rootViewController = BaseNavigationController(rootViewController: MainViewController.storyboard())
        window?.makeKeyAndVisible()
    }
}
