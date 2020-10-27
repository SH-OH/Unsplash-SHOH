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
    
    static var shared = ImageCache()
    
    private let lock: NSLock = NSLock()
    
    private var cache: [String: UIImage] = [:]
    
    private init() {}
    
    func getImage(_ key: String) -> UIImage? {
        let cachedImage = Queue.cache.queue.sync {
            self.cache[key]
        }
        Log.osh("[Get] Key : \(key), image : \(cachedImage)")
        return cachedImage
    }
    
    func getImage(_ key: String, completion: @escaping (UIImage?) -> ()) {
        self.lock.lock()
        defer { lock.unlock() }
        let cachedImage = self.cache[key]
//        Log.osh("get cached key : \(key)\n get cached image completion : \(cachedImage)")
        completion(cachedImage)
    }
    
    mutating func setImage(_ key: String, image: UIImage) {
        cache.updateValue(image, forKey: key)
        Log.osh("[Set] Key : \(key), image : \(image)")
    }
    
}
