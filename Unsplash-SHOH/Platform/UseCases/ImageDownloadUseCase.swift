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
    
    private func controlActivity(show: Bool,
                                 activityData: ForActivityData?) {
        guard let activityData = activityData else { return }
        NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                  show: show,
                                                  useLoading: activityData.isFirst)
    }
    
    func downloadImage(_ item: PhotoModel,
                       target: UIImageView,
                       size: CGSize,
                       imageCache: ImageCahe,
                       isHeader: Bool = false,
                       for activityData: ForActivityData? = nil) {
        guard let url = item.urls[.regular] else { return }
        let key = isHeader ? "header" : url.absoluteString
        if let cachedImage = imageCache.getImage(key) {
            DispatchQueue.main.async {
                target.image = cachedImage
            }
            return
        }
        
        self.controlActivity(show: true,
                             activityData: activityData)
        imageDownloader.retriveImage(url,
                                     size: size,
                                     imageCache: imageCache,
                                     isHeader: isHeader) { [self] (image) in
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
