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
    
    private var imageCache: ImageCache = ImageCache.shared
    
    func downloadImage(_ item: PhotoModel,
                       target: UIImageView,
                       for activityData: ForActivityData? = nil) {
        guard let url = item.urls[.regular] else { return }
//        if let cachedImage = imageCache.getImage(url.absoluteString) {
//            target.image = cachedImage
//            return
//        }
        
        imageCache.getImage(url.absoluteString) { (image) in
            if let cachedImage = image {
                DispatchQueue.main.async {
                    target.image = cachedImage
                }
                return
            }
            
            self.controlActivity(show: true,
                                 activityData: activityData)
            imageDownloader.retriveImage(url) { [self] (image) in
                UIView.transition(with: target,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve) {
                    let resizedImage = image.resizedImage(size: target.bounds.size)
                    self.imageCache.setImage(url.absoluteString, image: resizedImage)
                    Log.osh("origin image : \(image), resized image : \(resizedImage)")
                    target.image = resizedImage
                } completion: { (_) in
                    self.controlActivity(show: false,
                                         activityData: activityData)
                }
            }
        }
        
//        self.controlActivity(show: true,
//                             activityData: activityData)
//        imageDownloader.retriveImage(url) { [self] (image) in
//            UIView.transition(with: target,
//                              duration: 0.3,
//                              options: .transitionCrossDissolve) {
//                let resizedImage = image.resizedImage(size: target.bounds.size)
//                self.imageCache.setImage(url.absoluteString, image: resizedImage)
//                Log.osh("origin image : \(image), resized image : \(resizedImage)")
//                target.image = resizedImage
//            } completion: { (_) in
//                self.controlActivity(show: false,
//                                     activityData: activityData)
//            }
//        }
    }
    
    private func controlActivity(show: Bool,
                                  activityData: ForActivityData?) {
        guard let activityData = activityData else { return }
        NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                  show: show,
                                                  useLoading: activityData.isFirst)
    }
}

