//
//  MainViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit

final class MainViewController: BaseViewController {
    
    @IBOutlet private weak var listCollectionView: UICollectionView!
    
    var photoModels: [PhotoModel]? = [] {
        didSet {
            self.reloadData()
        }
    }
    
    private lazy var delegateFactory: ListLayoutCollectionViewFactory = {
        let factory = ListLayoutCollectionViewFactory(self,
                                                      targetCV: listCollectionView,
                                                      type: .Main)
        factory.parentController = self.navigationController()
        return factory
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegateFactory.requestGetPhotoList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
//            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search photos", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.listCollectionView.reloadData()
        }
    }
}

// Load NavigationController
extension MainViewController {
    private func navigationController() -> BaseNavigationController {
        guard let navigationController = navigationController as? BaseNavigationController else {
            preconditionFailure("네비게이션컨트롤러 불러오기 실패")
        }
        return navigationController
    }
}

// MARK: - ListLayoutCollectionViewFactoryDelegate
extension MainViewController: ListLayoutCollectionViewFactoryDelegate {}
