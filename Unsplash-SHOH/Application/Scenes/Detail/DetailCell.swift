//
//  DetailCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import UIKit.UICollectionViewCell

final class DetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var detailImage: UIImageView!
    
    func configure(_ imageData: ImageDownloader.ImageData) {
        guard let url = imageData.item.urls[.regular] else { return }
        ImageDownloader()
            .retriveImage(url,
                          size: frame.size,
                          imageCache: imageData.imageCache) { (image) in
                if let visibleImageCell = imageData.collectionView.cellForItem(at: imageData.indexPath) as? DetailCell {
                    UIView.transition(with: visibleImageCell.detailImage,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve) {
                        visibleImageCell.detailImage.image = image
                    }
                }
            }
    }
}
