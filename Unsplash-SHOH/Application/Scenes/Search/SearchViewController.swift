//
//  SearchViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/28.
//

import UIKit

final class SearchViewController: BaseViewController {
    
    @IBOutlet private weak var searchCollectionView: UICollectionView!
    @IBOutlet private weak var emptyView: UIView!
    
    var photoModels: [PhotoModel]? = [] {
        didSet {
            if let models = photoModels {
                DispatchQueue.main.async {
                    self.emptyView.isHidden = !models.isEmpty
                }
            }
        }
    }
    
    var searchedText: String?
    var parentController: BaseNavigationController?
    
    private lazy var delegateFactory: ListLayoutCollectionViewFactory = {
        let factory = ListLayoutCollectionViewFactory(self,
                                                      targetCV: searchCollectionView,
                                                      type: .search)
        factory.parentController = self.parentController
        factory.searchedText = self.searchedText
        return factory
    }()
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegateFactory.requestGetSearchList(searchedText)
    }
}

// MARK: - ListLayoutCollectionViewFactoryDelegate
extension SearchViewController: ListLayoutCollectionViewFactoryDelegate {}
