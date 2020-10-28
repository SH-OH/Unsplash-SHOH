//
//  ImageDownloader.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation
import UIKit

final class ImageDownloader {
    
    struct ImageData {
        let item: PhotoModel
        let imageCache: ImageCahe
        let collectionView: UICollectionView
        let indexPath: IndexPath
    }
    
    struct ForActivityData {
        let isFirst: Bool
        let parentViewController: UIViewController?
    }
    
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
                      activityData: ForActivityData? = nil,
                      completion: @escaping (UIImage) -> ()) {
        let key = isHeader ? "header" : url.absoluteString
        if let cachedImage = imageCache.getImage(key) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        guard task == nil else {
            return
        }
        
        self.controlActivity(show: true, activityData: activityData)
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
                        completion(resizedImage)
                        self.controlActivity(show: false, activityData: activityData)
                    }
                }
            }
            self.task?.resume()
        }
    }
    
}

extension ImageDownloader {
    private func controlActivity(show: Bool,
                                 activityData: ForActivityData?) {
        guard let activityData = activityData else { return }
        NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                  show: show,
                                                  useLoading: activityData.isFirst)
    }
}
