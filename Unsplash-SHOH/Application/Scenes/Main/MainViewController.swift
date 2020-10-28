//
//  MainViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit

final class MainViewController: BaseViewController {
    
    @IBOutlet private weak var listCollectionView: UICollectionView!
    @IBOutlet private weak var searchBar: IBSearchBar!
    
    private let search: SearchViewController = SearchViewController.storyboard()
    
    var photoModels: [PhotoModel]? = []
    
    private lazy var delegateFactory: ListLayoutCollectionViewFactory = {
        let factory = ListLayoutCollectionViewFactory(self,
                                                      targetCV: listCollectionView,
                                                      type: .list)
        factory.parentController = self.navigationController()
        return factory
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegateFactory.requestGetPhotoList()
        searchBar.delegate = self
    }
    
    @IBAction private func cancelSearch(_ sender: UIButton) {
        self.searchBar.text = nil
        self.detachSeach()
        self.searchBar.resignFirstResponder()
    }
}

// MARK: - Navigation Controller
extension MainViewController {
    private func navigationController() -> BaseNavigationController {
        guard let navigationController = navigationController as? BaseNavigationController else {
            preconditionFailure("네비게이션컨트롤러 불러오기 실패")
        }
        return navigationController
    }
    
    private func attachSearch() {
        guard !self.children.contains(search) else { return }
        search.parentController = self.navigationController()
        search.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(self.search)
        self.view.addSubview(self.search.view)
        NSLayoutConstraint.activate([
            self.search.view.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor),
            self.search.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.search.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.search.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.view.layoutIfNeeded()
        search.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.search.view.alpha = 1
            self.search.view.layoutIfNeeded()
        }
    }
    
    private func detachSeach() {
        guard self.children.contains(search) else { return }
        self.search.getSearchDelegateFactory().clearData()
        self.search.willMove(toParent: nil)
        self.search.view.removeFromSuperview()
        self.search.removeFromParent()
    }
}

// MARK: - ListLayoutCollectionViewFactoryDelegate
extension MainViewController: ListLayoutCollectionViewFactoryDelegate {}


// MARK - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search.searchedText = searchBar.text
        attachSearch()
        search.getSearchDelegateFactory().requestGetSearchList(searchBar.text)
    }
}
