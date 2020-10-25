//
//  MainViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit

class MainViewController: BaseViewController {
    
    private var photoModels: [PhotoModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    /// 화면 첫 진입으로 셀 이미지 로딩 보여주기 위한 Flag
    private var isFirstDownloadForLoading: Bool = true
    
    @IBOutlet private weak var listCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        requestGetPhotoList()
    }
    
    private func setDelegate() {
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        if let layout = listCollectionView.collectionViewLayout as? ListLayout {
            layout.delegate = self
        }
    }
    
    private func requestGetPhotoList() {
        guard let navigationController = navigationController as? BaseNavigationController else {
            return
        }
        PhotoUseCase(navigationController).getPhotoList(oldModels: photoModels) { [self] (resultModels) in
            self.photoModels = resultModels
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.listCollectionView.reloadData()
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ListCell.self, for: indexPath)
        if let item = self.photoModels[safe: indexPath.item] {
            let isFirst: Bool = indexPath.item == 0 && isFirstDownloadForLoading
            let data = ListCell.ForActivityData(isFirst: isFirst,
                                                parentViewController: navigationController)
            cell.configure(item, for: data)
            if isFirstDownloadForLoading {
                isFirstDownloadForLoading = false
            }
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        Log.osh(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        Log.osh(indexPath)
        let prefetchIndex: Bool = indexPath.item == photoModels.count-15
        if prefetchIndex {
            self.requestGetPhotoList()
        }
    }
}

extension MainViewController: ListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath) -> CGFloat {
        guard let item = self.photoModels[safe: indexPath.item] else { return .zero }
        let width = collectionView.bounds.width
        let height = CGFloat(item.height) * width / CGFloat(item.width)
        return height
    }
}
