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
    
    private func prepareURLRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url,
                                 timeoutInterval: NetworkManager.shared.timeout)
        request.httpMethod = NetworkManager.HTTPMethod.get.rawValue
        request.allHTTPHeaderFields = APIDomain.header
        return request
    }
    
    func retriveImage(_ url: URL,
                      size: CGSize,
                      imageCache: ImageCahe,
                      isHeader: Bool = false,
                      completion: ((UIImage) -> ())? = nil) {
        guard task == nil else {
            return
        }
        let request: URLRequest = self.prepareURLRequest(url)
        Queue.root.queue.async {
            self.task = NetworkManager.shared.session.dataTask(with: request) { [self] (data, _, error) in
                self.task = nil
                Queue.image.queue.async {
                    guard error == nil,
                          let data = data,
                          let image = UIImage(data: data) else {
                        return
                    }
                    let resizedImage = image.resizedImage(size: size)
                    let key = isHeader ? "header" : url.absoluteString
                    imageCache.setImage(key,
                                        image: resizedImage)
                    DispatchQueue.main.async {
                        completion?(resizedImage)
                    }
                }
            }
            self.task?.resume()
        }
    }
    
}
