//
//  MainViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit

class MainViewController: BaseViewController {
    
    @IBOutlet private weak var listCollectionView: UICollectionView!
    
    var photoModels: [PhotoModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    
    private lazy var delegateFactory: ListLayoutCollectionViewFactory = {
        return ListLayoutCollectionViewFactory(self,
                          targetCV: listCollectionView,
                          type: .Main)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegateFactory.requestGetPhotoList()
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
extension MainViewController: ListLayoutCollectionViewFactoryDelegate {
    var parentController: UIViewController {
        return self.navigationController()
    }
}
