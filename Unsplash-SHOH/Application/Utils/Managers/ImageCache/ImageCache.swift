//
//  ImageCache.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation
import UIKit.UIImage

struct ImageCache {
    
    enum Config {
        static let countLimit: Int = 500
    }
    
    static let shared = ImageCache()
    
    private let lock: NSLock = NSLock()
    
    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = Config.countLimit
        return cache
    }()
    
    func getImage(_ key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ key: String, image: UIImage) {
        lock.lock()
        defer { lock.unlock() }
        cache.setObject(image, forKey: key as NSString)
    }
    
}
