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
                      completion: @escaping (UIImage?, Bool) -> ()) {
        guard task == nil else {
            return
        }
        if let cachedImage = self.imageCache.getImage(url.absoluteString) {
            DispatchQueue.main.async {
                completion(cachedImage, true)
            }
            return
        }
        let request: URLRequest = self.prepareURLRequest(url)
        task = NetworkManager.shared.session.dataTask(with: request) { [self] (data, _, error) in
            self.task = nil
            Queue.image(url.absoluteString).queue.async {
                guard error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil, false)
                    }
                    return
                }
                self.imageCache.setImage(url.absoluteString, image: image)
                DispatchQueue.main.async {
                    completion(image, false)
                }
            }
        }
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}
