//
//  ListLayoutCollectionViewFactory.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import UIKit

protocol ListLayoutCollectionViewFactoryDelegate: class {
    var photoModels: [PhotoModel] { get set }
    var parentController: UIViewController { get }
}

final class ListLayoutCollectionViewFactory: NSObject {
    
    enum DataSourceType {
        case Main, Detail
    }
    
    weak var delegate: ListLayoutCollectionViewFactoryDelegate?
    
    /// 메인 화면 첫 진입으로 셀 이미지 로딩 보여주기 위한 Flag
    private var isFirstDownloadForLoading: Bool = true
    
    private let dataSourceType: DataSourceType
    
    init(_ delegate: ListLayoutCollectionViewFactoryDelegate,
         targetCV: UICollectionView,
         type: DataSourceType) {
        self.dataSourceType = type
        super.init()
        self.setDelegate(delegate,
                         targetCV: targetCV)
        
    }
    
    private func setDelegate(_ delegate: ListLayoutCollectionViewFactoryDelegate,
                             targetCV: UICollectionView) {
        self.delegate = delegate
        targetCV.dataSource = self
        targetCV.delegate = self
        if let layout = targetCV.collectionViewLayout as? ListLayout {
            layout.delegate = self
        }
    }
    
    func requestGetPhotoList() {
        guard let delegate = delegate else { return }
        PhotoUseCase(delegate.parentController).getPhotoList(oldModels: delegate.photoModels) { (resultModels) in
            delegate.photoModels = resultModels
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension ListLayoutCollectionViewFactory: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return delegate?.photoModels.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = delegate else {
            return .init()
        }
        switch dataSourceType {
        case .Main:
            let cell = collectionView.dequeue(ListCell.self, for: indexPath)
            if let item = delegate.photoModels[safe: indexPath.item] {
                let isFirst: Bool = indexPath.item == 0 && self.isFirstDownloadForLoading
                let data = ListCell.ForActivityData(isFirst: isFirst,
                                                    parentViewController: delegate.parentController)
                cell.configure(item, for: data)
                if self.isFirstDownloadForLoading {
                    self.isFirstDownloadForLoading = false
                }
            }
            return cell
        case .Detail:
            return .init()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ListLayoutCollectionViewFactory: UICollectionViewDelegateFlowLayout {
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
        switch dataSourceType {
        case .Main:
            let detail = DetailViewController.storyboard()
            delegate?.parentController.present(detail, animated: true, completion: nil)
        case .Detail:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        switch dataSourceType {
        case .Main:
            let prefetchIndex: Bool = indexPath.item == delegate.photoModels.count-15
            if prefetchIndex {
                self.requestGetPhotoList()
            }
        case .Detail:
            break
        }
    }
}

// MARK: - ListLayoutDelegate
extension ListLayoutCollectionViewFactory: ListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath) -> CGFloat {
        guard let item = delegate?.photoModels[safe: indexPath.item] else { return .zero }
        let width = collectionView.bounds.width
        let height = CGFloat(item.height) * width / CGFloat(item.width)
        return height
    }
}
