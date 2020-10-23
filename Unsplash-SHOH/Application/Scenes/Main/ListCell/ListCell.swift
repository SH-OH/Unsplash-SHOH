//
//  ListCell.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit

final class ListCell: UICollectionViewCell {
    
    @IBOutlet private weak var listImage: UIImageView!
    @IBOutlet private weak var listImageNameLb: UILabel!
    
//    private let imageDownloader: ImageDownloader = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Log.osh("")
    }
    
    required init?(coder: NSCoder) {
        Log.osh("")
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        Log.osh("")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        Log.osh("")
//        listImageNameLb.text = nil
//        listImage.image = nil
//        imageDownloader.cancel()
    }
    
    func configure(_ item: PhotoModel) {
        Log.osh("")
        contentView.backgroundColor = item.color
//        download(item)
        listImageNameLb.text = makeName(item.user)
        listImage.backgroundColor = item.color
    }
    
//    private func download(_ item: PhotoModel) {
//        guard let url = item.urls[.regular] else { return }
//        imageDownloader.retriveImage(url) { [weak self] (image) in
//            self?.listImage.image = image
//        }
//    }
    
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
