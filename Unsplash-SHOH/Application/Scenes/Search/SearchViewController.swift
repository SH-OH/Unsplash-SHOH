//
//  SearchViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/28.
//

import UIKit

final class SearchViewController: BaseViewController {
    
    @IBOutlet private weak var searchCollectionView: UICollectionView! {
        didSet {
            searchCollectionView.backgroundView = emptyView
            searchCollectionView.backgroundView?.isHidden = true
        }
    }
    @IBOutlet private weak var emptyView: UIView!
    
    var photoModels: [PhotoModel]? = []
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
    
    func getSearchDelegateFactory() -> ListLayoutCollectionViewFactory {
        return delegateFactory
    }
}

// MARK: - ListLayoutCollectionViewFactoryDelegate
extension SearchViewController: ListLayoutCollectionViewFactoryDelegate {}
