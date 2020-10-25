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
    
    var photoModels: [PhotoModel]? {
        didSet {
            self.reloadData()
        }
    }
    
    private lazy var delegateFactory: ListLayoutCollectionViewFactory = {
       return ListLayoutCollectionViewFactory(self,
                                              targetCV: detailCollectionView,
                                              type: .Detail)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTitleByOS()
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.detailCollectionView.reloadData()
        }
    }
    
    // Actions
    
    @IBAction private func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// Temp Methods
extension DetailViewController {
    // SF Symbol 아이콘을 사용해서, 임시로 iOS 13 이하에서는 버튼 타이틀로 보여주도록 함.
    private func setButtonTitleByOS() {
        if #available(iOS 13, *) { return }
        closeButton.setTitle("Close", for: .normal)
        shareButton.setTitle("Share", for: .normal)
    }
}

// MARK: - ListLayoutCollectionViewFactoryDelegate
extension DetailViewController: ListLayoutCollectionViewFactoryDelegate {}
