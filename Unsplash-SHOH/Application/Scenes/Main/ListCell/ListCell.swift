//
//  ListCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit

final class ListCell: UICollectionViewCell {
    
    struct ForActivityData {
        let isFirst: Bool
        let parentViewController: UIViewController?
    }
    
    @IBOutlet private weak var listImage: UIImageView!
    @IBOutlet private weak var listImageNameLb: UILabel!
    
    private let imageDownloader: ImageDownloader = .init()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        listImage.image = nil 
    }
    
    func configure(_ item: PhotoModel,
                   for activityData: ForActivityData) {
        listImageNameLb.text = makeName(item.user)
        listImage.backgroundColor = item.color
        downloadImage(item, for: activityData)
    }
    
    private func downloadImage(_ item: PhotoModel,
                               for activityData: ForActivityData) {
        guard let url = item.urls[.regular] else { return }
        NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                  show: true,
                                                  useLoading: activityData.isFirst)
        imageDownloader.retriveImage(url) { [self] (image, cached) in
            self.listImage.image = image
            if !cached {
                NetworkManager.shared.showNetworkActivity(activityData.parentViewController,
                                                          show: false,
                                                          useLoading: activityData.isFirst)
            }
        }
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
