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
                      completion: @escaping (UIImage) -> ()) {
        guard task == nil else {
            return
        }
        let request: URLRequest = self.prepareURLRequest(url)
        task = NetworkManager.shared.session.dataTask(with: request) { [self] (data, _, error) in
            self.task = nil
            Queue.image(url.absoluteString).queue.async {
                guard error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}
