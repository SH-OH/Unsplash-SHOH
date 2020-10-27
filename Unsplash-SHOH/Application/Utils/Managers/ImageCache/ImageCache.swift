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
        static let countLimit: Int = 300
    }
    
    static let shared = ImageCache()
    
    private let lock: NSLock = NSLock()
    
    private var cache: [String: UIImage] = [:]
    
    func getImage(_ key: String) -> UIImage? {
        self.lock.lock()
        defer { lock.unlock() }
        let cachedImage = self.cache[key]
        Log.osh("get cached key : \(key)\n get cached image completion : \(cachedImage)")
        return cachedImage
    }
    
    func getImage(_ key: String, completion: @escaping (UIImage?) -> ()) {
        Queue.cache.queue.async {
            self.lock.lock()
            defer { lock.unlock() }
            let cachedImage = self.cache[key]
            Log.osh("get cached key : \(key)\n get cached image completion : \(cachedImage)")
            completion(cachedImage)
        }
    }
    
    mutating func setImage(_ key: String, image: UIImage) {
        self.lock.lock()
        defer { lock.unlock() }
        self.cache.updateValue(image, forKey: key)
        Log.osh("set cache key : \(key)\n set cache image : \(image)")
    }
    
}
