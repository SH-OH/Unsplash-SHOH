//
//  ImageDownloadUseCase.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import UIKit.UIImage

struct ImageDownloadUseCase {
    
    struct ForActivityData {
        let isFirst: Bool
        let parentViewController: UIViewController?
    }
    
    private let imageDownloader: ImageDownloader = .init()
    
    func downloadImage(_ item: PhotoModel,
                       target: UIImageView,
                       size: CGSize,
                       for activityData: ForActivityData? = nil) {
        self.getCachedImage(item.id,
                            target: target) {
            guard let regularUrl = item.urls[.regular] else { return }
//            let url = self.resizedURL(regularUrl, size: size)
            
            self.controlActivity(show: true,
                                 activityData: activityData)
            imageDownloader.retriveImage(regularUrl, size: size) { [self] (image) in
                let resizedImage = image.resizedImage(size: size)
                Queue.cache.queue.async {
                    ImageCache.shared.setImage(item.id, image: resizedImage)
                }
                DispatchQueue.main.async {
                    UIView.transition(with: target,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve) {
                        target.image = image
                    } completion: { (_) in
                        self.controlActivity(show: false,
                                             activityData: activityData)
                    }
                }
            }
        }
    }
    
    private func getCachedImage(_ id: String,
                                target: UIImageView,
                                completion: @escaping () -> ()) {
        Queue.cache.queue.async {
            if let cachedImage = ImageCache.shared.getImage(id) {
                DispatchQueue.main.async {
                    target.image = cachedImage
                }
            } else {
                completion()
            }
        }
    }
    
    private func resizedURL(_ url: URL, size: CGSize) -> URL {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return url
        }
        if let queryItems = urlComponents.queryItems {
            for var item in queryItems where item.name == "w" {
                item.value = "\(size)"
            }
            urlComponents.queryItems = queryItems
        }
        return urlComponents.url ?? url
    }
    
    private func controlActivity(show: Bool,
                                  activityData: ForActivityData?) {
        guard let activityData = activityData else { return }
        NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                  show: show,
                                                  useLoading: activityData.isFirst)
    }
}

