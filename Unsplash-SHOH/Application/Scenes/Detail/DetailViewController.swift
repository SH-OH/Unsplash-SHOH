//
//  DetailViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import UIKit

final class DetailViewController: BaseViewController {
    
    @IBOutlet private weak var nameButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var detailCollectionView: UICollectionView!
    
    
    
    private func setDelegate() {
//        detailCollectionView.delegate = self
//        detailCollectionView.dataSource = self
//        if let layout = detailCollectionView.collectionViewLayout as? ListLayout {
//            layout.scrollDirection = .horizontal
//            layout.delegate = self
//        }
    }
}
