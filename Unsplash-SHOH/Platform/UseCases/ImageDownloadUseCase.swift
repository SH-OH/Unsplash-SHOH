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
        guard let regularUrl = item.urls[.regular] else { return }
        let url = self.resizedURL(regularUrl, size: target.bounds.size)
        if let cachedImage = ImageCache.shared.getImage(url.absoluteString) {
            DispatchQueue.main.async {
                target.image = cachedImage
            }
            return
        }
        
        self.controlActivity(show: true,
                             activityData: activityData)
        imageDownloader.retriveImage(url, size: size) { [self] (image) in
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
    
    private func resizedURL(_ url: URL, size: CGSize) -> URL {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return url
        }
        if let queryItems = urlComponents.queryItems {
            for var item in queryItems where item.name == "w" {
                item.value = "\(size)"
            }
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

