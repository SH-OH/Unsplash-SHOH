//
//  MainCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UICollectionViewCell

final class MainCell: UICollectionViewCell {
    
    struct ForActivityData {
        let isFirst: Bool
        let parentViewController: UIViewController?
    }
    
    @IBOutlet private weak var listImage: UIImageView!
    @IBOutlet private weak var listImageNameLb: UILabel!
    
    private let imageDownloader: ImageDownloader = .init()
    private let imageDownloadUseCase: ImageDownloadUseCase = .init()
    
    
    private var index: Int?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        listImage.image = nil
        Log.osh("index : \(index), image size : \(listImage.image?.size)")
    }
    
    func configure(_ item: PhotoModel,
                   for activityData: ImageDownloadUseCase.ForActivityData,
                   index: Int) {
        self.index = index
        Log.osh("index : \(index), image size : \(listImage.image?.size)")
        listImageNameLb.text = makeName(item.user)
        listImage.backgroundColor = item.color
        imageDownloadUseCase.downloadImage(item,
                                           target: listImage,
                                           for: activityData,
                                           index: index)
    }
    
    private func makeName(_ user: PhotoUser?) -> String {
        if let name = user?.name {
            return name
        }
        if let firstName = user?.firstName {
            if let lastName = user?.lastName {
                return "\(firstName) \(lastName)"
            }
            return firstName
        }
        return user?.username ?? ""
    }
}
