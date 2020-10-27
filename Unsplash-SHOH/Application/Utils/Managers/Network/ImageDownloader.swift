//
//  ImageDownloader.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation
import UIKit

final class ImageDownloader {
    
    var task: URLSessionDataTask?
    
    private var imageCache: ImageCache = ImageCache.shared
    
    private func prepareURLRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url,
                                 timeoutInterval: NetworkManager.shared.timeout)
        request.httpMethod = NetworkManager.HTTPMethod.get.rawValue
        request.allHTTPHeaderFields = APIDomain.header
        return request
    }
    
    func retriveImage(_ url: URL,
                      size: CGSize,
                      completion: @escaping (UIImage) -> ()) {
        guard task == nil else {
            return
        }
        let request: URLRequest = self.prepareURLRequest(url)
        Queue.root.queue.async {
            self.task = URLSession(configuration: .default).dataTask(with: request) { [self] (data, _, error) in
                self.task = nil
                Queue.imageDownload.queue.async {
                    guard error == nil,
                          let data = data,
                          let image = UIImage(data: data) else {
                        return
                    }
                    completion(image)
                    //                    let resizedImage = image.resizedImage(size: size)
                    //                    imageCache.setImage(url.absoluteString,
                    //                                        image: resizedImage)
                    //                    DispatchQueue.main.async {
                    //                        completion(image)
                    //                    }
                }
            }
            self.task?.resume()
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
}

final class ImageDownloadManager {
    
    static let shared = ImageDownloadManager()
    
    private var imageDownloadTasks: [String: URLSessionDataTask]
    private var imageCache: ImageCache
    private init() {
        imageDownloadTasks = [:]
        imageCache = .shared
    }
    
    
    private func prepareURLRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url,
                                 timeoutInterval: NetworkManager.shared.timeout)
        request.httpMethod = NetworkManager.HTTPMethod.get.rawValue
        request.allHTTPHeaderFields = APIDomain.header
        return request
    }
    
    
    func downloadImage(_ url: URL,
                       size: CGSize,
                       completion: @escaping (UIImage?) -> ()) {
        
        let urlString: String = url.absoluteString
        if let cachedImage = imageCache.getImage(urlString) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        guard imageDownloadTasks[urlString] == nil else { return }
        
        let request: URLRequest = self.prepareURLRequest(url)
        Queue.root.queue.async {
            let task = NetworkManager.shared.session.dataTask(with: request) { (data, _, error) in
                guard error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                let resizedImage = image.resizedImage(size: size)
                Queue.cache.queue.async(flags: .barrier) {
                    self.imageCache.setImage(urlString, image: resizedImage)
                }
                Queue.imageDownload.queue.sync {
                    _ = self.imageDownloadTasks.removeValue(forKey: urlString)
                }
                
                DispatchQueue.main.async {
                    completion(resizedImage)
                }
            }
            Queue.imageDownload.queue.async(flags: .barrier, execute: {
                _ = self.imageDownloadTasks.updateValue(task, forKey: urlString)
            })
            task.resume()
        }
    }
}
