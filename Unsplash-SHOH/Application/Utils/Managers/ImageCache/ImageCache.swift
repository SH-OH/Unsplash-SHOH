//
//  ImageCache.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation
import UIKit.UIImage

final class ImageCahe {
    
    private var cache: [String: UIImage]
    
    private let lock: NSLock
    
    init(cache: [String: UIImage] = [:]) {
        self.cache = cache
        self.lock = .init()
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
    
    func removeAll() {
        Queue.cache.queue.async(flags: .barrier) { [self] in
            lock.lock()
            defer { lock.unlock() }
            cache.removeAll(keepingCapacity: true)
        }
    }
    
    func getCacheList() -> [String: UIImage] {
        return cache
    }
}
