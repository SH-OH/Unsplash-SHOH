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
                       for activityData: ForActivityData? = nil) {
        guard let url = item.urls[.regular] else { return }
        self.controlActivity(show: true,
                             activityData: activityData)
        imageDownloader.retriveImage(url) { [self] (image, cached) in
            if !cached {
                UIView.transition(with: target,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve) {
                    target.image = image
                } completion: { (_) in
                    self.controlActivity(show: false,
                                         activityData: activityData)
                }
            } else {
                target.image = image
            }
        }
    }
    
    private func controlActivity(show: Bool,
                                  activityData: ForActivityData?) {
        guard let activityData = activityData else { return }
        NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                  show: show,
                                                  useLoading: activityData.isFirst)
    }
}

