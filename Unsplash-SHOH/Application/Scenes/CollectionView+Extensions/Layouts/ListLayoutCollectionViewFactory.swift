//
//  ListLayoutCollectionViewFactory.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import UIKit

protocol ListLayoutCollectionViewFactoryDelegate: class {
    var photoModels: [PhotoModel]? { get set }
}

final class ListLayoutCollectionViewFactory: NSObject {
    
    enum DataSourceType {
        case Main, Detail
    }
    
    weak var delegate: ListLayoutCollectionViewFactoryDelegate?
    
    var parentController: UIViewController?
    var selectedIndexPath: IndexPath?
    
    /// 메인 화면 첫 진입으로 셀 이미지 로딩 보여주기 위한 Flag
    /// 상세 화면 시작 위치 설정을 위한 Flag
    private var isFirstLoadFlag: Bool = true
    
    private let dataSourceType: DataSourceType
    
    init(_ delegate: ListLayoutCollectionViewFactoryDelegate,
         targetCV: UICollectionView,
         type: DataSourceType) {
        self.dataSourceType = type
        super.init()
        self.setDelegate(delegate,
                         targetCV: targetCV)
    }
    
    deinit {
        print("\(dataSourceType) Factory deinit !!!!!!!!!!!")
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
        guard let photoModels = delegate?.photoModels else { return }
        PhotoUseCase().getPhotoList(oldModels: photoModels) { [self] (resultModels) in
            delegate?.photoModels = resultModels
        }
    }
    
    func findDataSourceType() -> DataSourceType {
        return dataSourceType
    }
    
}

// MARK: - UICollectionViewDataSource
extension ListLayoutCollectionViewFactory: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return delegate?.photoModels?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch dataSourceType {
        case .Main:
            let cell = collectionView.dequeue(MainCell.self, for: indexPath)
            if let item = self.delegate?.photoModels?[safe: indexPath.item] {
                let isFirst: Bool = indexPath.item == 0 && self.isFirstLoadFlag
                let data = ImageDownloadUseCase.ForActivityData(isFirst: isFirst,
                                                                parentViewController: self.parentController)
                cell.configure(item, for: data)
                if self.isFirstLoadFlag {
                    self.isFirstLoadFlag = false
                }
            }
            return cell
        case .Detail:
            let cell = collectionView.dequeue(DetailCell.self, for: indexPath)
            if let item = self.delegate?.photoModels?[safe: indexPath.item] {
                cell.configure(item)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard dataSourceType == .Main else { return .init() }
        Log.osh("indexPath : \(indexPath)")
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "MainHeaderView",
                                                                         for: indexPath)
//        let headerView = collectionView.dequeue(UICollectionReusableView.self,
//                                                kind: kind,
//                                                for: indexPath)
        
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ListLayoutCollectionViewFactory: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return dataSourceType == .Main ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return dataSourceType == .Main ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard dataSourceType == .Main else { return .zero }
        let width: CGFloat = collectionView.bounds.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        Log.osh(indexPath)
        switch dataSourceType {
        case .Main:
            let detail = DetailViewController.storyboard()
            detail.photoModels = delegate?.photoModels
            detail.mainCollectionView = collectionView
            detail.initialSelectedIndexPath = indexPath
            self.parentController?.present(detail, animated: true, completion: nil)
        case .Detail:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let photoModels = delegate?.photoModels else { return }
        switch dataSourceType {
        case .Main:
            let prefetchIndex: Bool = indexPath.item == photoModels.count-15
            if prefetchIndex {
                self.requestGetPhotoList()
            }
        case .Detail:
            if self.isFirstLoadFlag && indexPath.item == 0 {
                if let selectedIndexPath = selectedIndexPath {
                    collectionView.scrollToItem(at: selectedIndexPath,
                                                at: .centeredHorizontally,
                                                animated: false)
                }
                self.isFirstLoadFlag = false
                return
            }
            let prefetchIndex: Bool = indexPath.item == photoModels.count-15
            if prefetchIndex {
                self.requestGetPhotoList()
            }
        }
    }
}

// MARK: - ListLayoutDelegate
extension ListLayoutCollectionViewFactory: ListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        photoHeightForItemAt indexPath: IndexPath) -> CGFloat {
        guard let item = delegate?.photoModels?[safe: indexPath.item] else { return .zero }
        let width = collectionView.bounds.width
        let height = CGFloat(item.height) * width / CGFloat(item.width)
        return height
    }
}
