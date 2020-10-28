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
        case list, detail, search
    }
    
    weak var delegate: ListLayoutCollectionViewFactoryDelegate?
    
    var parentController: UIViewController?
    var selectedIndexPath: IndexPath? {
        didSet {
            detailConfigure()
        }
    }
    var searchedText: String?
    
    let dataSourceType: DataSourceType
    let targetCV: UICollectionView
    
    /// 메인 화면 첫 진입으로 셀 이미지 로딩 보여주기 위한 Flag
    /// 상세 화면 시작 위치 설정을 위한 Flag
    private var isFirstLoadFlag: Bool = true
    
    private let imageCache: ImageCahe = ImageCahe()
    
    private let photoUseCase: PhotoUseCase = PhotoUseCase()
    
    init(_ delegate: ListLayoutCollectionViewFactoryDelegate,
         targetCV: UICollectionView,
         type: DataSourceType) {
        self.dataSourceType = type
        self.targetCV = targetCV
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
    
    private func detailConfigure() {
        if let detail = self.delegate as? DetailViewController,
           let selectedIndex = selectedIndexPath?.item,
           let selectedItem = delegate?.photoModels?[selectedIndex] {
            detail.configure(selectedItem)
        }
    }
    
    func requestGetPhotoList() {
        guard let photoModels = delegate?.photoModels else { return }
        photoUseCase.getPhotoList(oldModels: photoModels) { [self] (resultModels) in
            delegate?.photoModels = resultModels
            reloadData()
        }
    }
    
    func requestGetSearchList(_ curSearchedText: String?) {
        guard let curSearchedText = curSearchedText,
              let photoModels = delegate?.photoModels else { return }
        let isChanged: Bool = self.searchedText != curSearchedText
        if self.searchedText != curSearchedText {
            self.searchedText = curSearchedText
        }
        let oldModels: [PhotoModel] = isChanged
            ? []
            : photoModels
        
        clearData()
        
        if isChanged {
            targetCV.scrollToItem(at: IndexPath(item: 0, section: 0),
                                  at: .top,
                                  animated: false)
        }
        
        photoUseCase.getSearchList(curSearchedText,
                                   isChanged: isChanged,
                                   oldModels: oldModels) { [self] (resultModels)  in
            delegate?.photoModels = resultModels
            controlEmptyView(resultModels)
            reloadData()
        }
    }
    
    func clearData() {
        delegate?.photoModels = []
        imageCache.removeAll()
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.targetCV.reloadData()
        }
    }
    
    private func controlEmptyView(_ resultModels: [PhotoModel]) {
        guard dataSourceType == .search else { return }
        DispatchQueue.main.async {
            if let backgroundView = self.targetCV.backgroundView {
                backgroundView.isHidden = !resultModels.isEmpty
            }
        }
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
        case .list, .search:
            let cell = collectionView.dequeue(ListCell.self, for: indexPath)
            if let item = self.delegate?.photoModels?[safe: indexPath.item] {
                let imageData = ImageDownloader.ImageData(item: item,
                                                          imageCache: imageCache,
                                                          collectionView: collectionView,
                                                          indexPath: indexPath)
                let isFirst: Bool = indexPath.item == 0 && self.isFirstLoadFlag
                let activityData = ImageDownloader.ForActivityData(isFirst: isFirst,
                                                           parentViewController: self.parentController)
                cell.configure(imageData,
                               activityData: activityData)
                
                if self.isFirstLoadFlag {
                    self.isFirstLoadFlag = false
                }
            }
            return cell
        case .detail:
            let cell = collectionView.dequeue(DetailCell.self, for: indexPath)
            if let item = self.delegate?.photoModels?[safe: indexPath.item] {
                let imageData = ImageDownloader.ImageData(item: item,
                                                          imageCache: imageCache,
                                                          collectionView: collectionView,
                                                          indexPath: indexPath)
                cell.configure(imageData)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard dataSourceType == .list else { return .init() }
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeue(MainHeaderView.self,
                                                    kind: kind,
                                                    for: indexPath)
            if let item = self.delegate?.photoModels?.last {
                let imageData = ImageDownloader.ImageData(item: item,
                                                          imageCache: imageCache,
                                                          collectionView: collectionView,
                                                          indexPath: indexPath)
                headerView.configure(imageData)
            }
            return headerView
        default:
            return .init()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ListLayoutCollectionViewFactory: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return dataSourceType == .detail ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return dataSourceType == .detail ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard dataSourceType == .list else { return .zero }
        let width: CGFloat = collectionView.bounds.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        switch dataSourceType {
        case .list, .search:
            let detail = DetailViewController.storyboard()
            detail.photoModels = delegate?.photoModels
            self.selectedIndexPath = indexPath
            detail.prevDelegateFactory = self
            self.parentController?.present(detail, animated: true, completion: nil)
        case .detail:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let photoModels = delegate?.photoModels else { return }
        switch dataSourceType {
        case .list:
            let prefetchIndex: Bool = indexPath.item == photoModels.count-15
            if prefetchIndex {
                self.requestGetPhotoList()
            }
        case .detail:
            if self.isFirstLoadFlag && indexPath.item == 0 {
                if let selectedIndexPath = selectedIndexPath {
                    collectionView.scrollToItem(at: selectedIndexPath,
                                                at: .centeredHorizontally,
                                                animated: false)
                }
                
                self.isFirstLoadFlag = false
                return
            }
            self.selectedIndexPath = indexPath
            let prefetchIndex: Bool = indexPath.item == photoModels.count-15
            if prefetchIndex {
                self.requestGetPhotoList()
            }
        case .search:
            let prefetchIndex: Bool = indexPath.item == photoModels.count-15
            if prefetchIndex {
                self.requestGetSearchList(self.searchedText)
            }
            break
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
