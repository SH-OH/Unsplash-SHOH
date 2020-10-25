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
    
    var initialSelectedIndexPath: IndexPath?
    var mainCollectionView: UICollectionView?
    var photoModels: [PhotoModel]? {
        didSet {
            self.reloadData()
        }
    }
    
    private lazy var delegateFactory: ListLayoutCollectionViewFactory = {
        let factory = ListLayoutCollectionViewFactory(self,
                                                      targetCV: detailCollectionView,
                                                      type: .Detail)
        return factory
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTitleByOS()
        delegateFactory.selectedIndexPath = initialSelectedIndexPath
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.detailCollectionView.reloadData()
        }
    }
    
    // Actions
    
    @IBAction private func closeAction(_ sender: UIButton) {
        if let visibleIndex = detailCollectionView.indexPathsForVisibleItems.first,
           let photoModels = photoModels {
            var scrollPosition: UICollectionView.ScrollPosition = .centeredVertically
            switch visibleIndex.item {
            case photoModels.count-1:
                scrollPosition = .bottom
            default:
                break
            }
            mainCollectionView?.scrollToItem(at: visibleIndex,
                                            at: scrollPosition,
                                            animated: false)
        }
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
