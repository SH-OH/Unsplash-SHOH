//
//  ListCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UICollectionViewCell

final class ListCell: UICollectionViewCell {
    
    @IBOutlet private weak var listImage: UIImageView!
    @IBOutlet private weak var listImageNameLb: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        listImage.image = nil
    }
    
    func configure(_ imageData: ImageDownloader.ImageData,
                   activityData: ImageDownloader.ForActivityData?) {
        listImageNameLb.text = imageData.item.user?.makeName()
        listImage.backgroundColor = imageData.item.color
        
        
        if let url = imageData.item.urls[.regular] {
            ImageDownloader()
                .retriveImage(url,
                              size: frame.size,
                              imageCache: imageData.imageCache,
                              activityData: activityData) { (image) in
                    if let visibleImageCell = imageData.collectionView.cellForItem(at: imageData.indexPath) as? ListCell {
                        UIView.transition(with: visibleImageCell.listImage,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve) {
                            visibleImageCell.listImage.image = image
                        }
                    }
                }
        }
    }
}
