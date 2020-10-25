//
//  DetailCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import UIKit.UICollectionViewCell

final class DetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var detailImage: UIImageView!
    
    private let imageDownloadUseCase: ImageDownloadUseCase = .init()
    
    func configure(_ item: PhotoModel) {
        imageDownloadUseCase.downloadImage(item,
                                           target: detailImage)
    }
}
