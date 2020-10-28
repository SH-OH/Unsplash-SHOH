//
//  MainHeaderView.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/27.
//

import UIKit

final class MainHeaderView: UICollectionReusableView {
    
    @IBOutlet private weak var headerImage: UIImageView!
    
    func configure(_ imageData: ImageDownloader.ImageData) {
        if let url = imageData.item.urls[.regular] {
            ImageDownloader()
                .retriveImage(url,
                              size: frame.size,
                              imageCache: imageData.imageCache,
                              isHeader: true) { (image) in
                    let kind = UICollectionView.elementKindSectionHeader
                    if let visibleHeaderView = imageData.collectionView.supplementaryView(forElementKind: kind,
                                                                                          at: imageData.indexPath) as? MainHeaderView {
                        UIView.transition(with: visibleHeaderView.headerImage,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve) {
                            visibleHeaderView.headerImage.image = image
                        }
                    }
                }
        }
    }
}
