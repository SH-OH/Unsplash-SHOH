//
//  ImageCache.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation
import UIKit.UIImage

final class ImageCache {
    
    static let shared = ImageCache()
    
    private var cache: [String: UIImage]
    
    private let lock: NSLock = NSLock()
    
    private init() {
        cache = [:]
    }
    
    func getImage(_ key: String) -> UIImage? {
        Queue.cache.queue.sync {
            lock.lock()
            defer { lock.unlock() }
            return cache[key]
        }
    }
    
    func setImage(_ key: String, image: UIImage) {
        Queue.cache.queue.async(flags: .barrier) { [self] in
            lock.lock()
            defer { lock.unlock() }
            cache.updateValue(image, forKey: key)
        }
    }
    
}
