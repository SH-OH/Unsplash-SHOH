//
//  MainHeaderView.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/27.
//

import UIKit

final class MainHeaderView: UICollectionReusableView {
    
    @IBOutlet private weak var headerImage: UIImageView!
    
    func configure(_ item: PhotoModel,
                   imageCache: ImageCahe) {
        ImageDownloadUseCase().downloadImage(item,
                                             target: headerImage,
                                             size: frame.size,
                                             imageCache: imageCache,
                                             isHeader: true)
    }
}
