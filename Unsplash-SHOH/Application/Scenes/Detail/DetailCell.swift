//
//  DetailCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import UIKit.UICollectionViewCell

final class DetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var detailImage: UIImageView!
    
    func configure(_ item: PhotoModel,
                   imageCache: ImageCahe) {
        ImageDownloadUseCase().downloadImage(item,
                                           target: detailImage,
                                           size: frame.size,
                                           imageCache: imageCache)
    }
}
