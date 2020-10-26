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
    
    private let imageCache: ImageCache = ImageCache.shared
    
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
            self.task = NetworkManager.shared.session.dataTask(with: request) { [self] (data, _, error) in
                self.task = nil
                Queue.image.queue.async {
                    guard error == nil,
                          let data = data,
                          let image = UIImage(data: data) else {
                        return
                    }
                    let resizedImage = image.resizedImage(size: size)
                    imageCache.setImage(url.absoluteString,
                                        image: resizedImage)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
            self.task?.resume()
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
}

extension ImageDownloader {
    
    func downloadToCachingImage(_ url: URL, completion: ((UIImage?, Bool) -> ())? = nil) {
        guard task == nil else {
            return
        }
        
        imageCache.getImage(url.absoluteString) { (image) in
            if let cachedImage = image {
                DispatchQueue.main.async {
                    completion?(cachedImage, false)
                }
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
                        imageCache.setImage(url.absoluteString, image: image)
                        DispatchQueue.main.async {
                            completion?(image, true)
                        }
                    }
                }
                self.task?.resume()
            }
        }
    }
    
    
    func downloadImage(_ item: PhotoModel,
                       target: UIImageView,
                       for activityData: ImageDownloadUseCase.ForActivityData? = nil,
                       index: Int) {
        guard let url = item.urls[.regular] else { return }
        imageCache.getImage(url.absoluteString) { (image) in
            if let cachedImage = image {
                DispatchQueue.main.async {
                    target.image = cachedImage
                    Log.osh("index : \(index), cached image set size : \(target.image?.size)")
                }
                return
            }
            
            self.controlActivity(show: true,
                                 activityData: activityData)
            self.retriveImage(url, size: target.frame.size) { [self] (image) in
                DispatchQueue.main.async {
                    UIView.transition(with: target,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve) {
                        target.image = image
                        Log.osh("index : \(index), not cached image set size : \(target.image?.size)")
                    } completion: { (_) in
                        self.controlActivity(show: false,
                                             activityData: activityData)
                    }
                }
            }
        }
    }
    
    private func controlActivity(show: Bool,
                                 activityData: ImageDownloadUseCase.ForActivityData?) {
        guard let activityData = activityData else { return }
        NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                  show: show,
                                                  useLoading: activityData.isFirst)
    }
}
