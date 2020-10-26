//
//  UIIMage+Extensions.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/26.
//

import UIKit.UIImage

extension UIImage {
    func resizedImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
