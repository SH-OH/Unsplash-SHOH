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
    
    // reusing image
    // 1. 첫번째 이미지가 더 크고, == 2. 두번째 이미지가 작아야댐.
    // 2. 첫번째 이미지가 작으니까, reusing된 상태(image = nil) 된 상태에서 먼저 response 되야되요.
    
    private let imageDownloader: ImageDownloader = .init()
    
    private var imageCache: ImageCache = ImageCache.shared
    
    func downloadImage(_ item: PhotoModel,
                       target: UIImageView,
                       for activityData: ForActivityData? = nil,
                       index: Int) {
        guard let regularUrl = item.urls[.regular] else { return }
        let url = self.resizedURL(regularUrl, size: target.bounds.size)
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
            imageDownloader.retriveImage(url) { [self] (image) in
                UIView.transition(with: target,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve) {
                    self.imageCache.setImage(url.absoluteString, image: image)
                    target.image = image
                    Log.osh("index : \(index), not cached image set size : \(target.image?.size)")
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

