//
//  MainHeaderView.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/27.
//

import UIKit

final class MainHeaderView: UICollectionReusableView {
    
    @IBOutlet private weak var headerImage: UIImageView!
    @IBOutlet private weak var searchBar: IBSearchBar!
    
    func configure(_ item: PhotoModel) {
        ImageDownloadUseCase().downloadImage(item,
                                             target: headerImage,
                                             size: frame.size,
                                             isHeader: true)
    }
}
