//
//  ListCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UICollectionViewCell

final class ListCell: UICollectionViewCell {
    
    struct ForActivityData {
        let isFirst: Bool
        let parentViewController: UIViewController?
    }
    
    @IBOutlet private weak var listImage: UIImageView!
    @IBOutlet private weak var listImageNameLb: UILabel!
    
    private let imageDownloadUseCase: ImageDownloadUseCase = .init()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        listImage.image = nil
    }
    
    func configure(_ item: PhotoModel,
                   imageCache: ImageCahe,
                   for activityData: ImageDownloadUseCase.ForActivityData) {
        listImageNameLb.text = item.user?.makeName()
        listImage.backgroundColor = item.color
        ImageDownloadUseCase().downloadImage(item,
                                           target: listImage,
                                           size: frame.size,
                                           imageCache: imageCache,
                                           for: activityData)
    }
}
