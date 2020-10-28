//
//  ListLayout.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UICollectionViewLayout

protocol ListLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView,
                        photoHeightForItemAt indexPath:IndexPath) -> CGFloat
}

final class ListLayout: UICollectionViewFlowLayout {
    
    enum CacheKey: Hashable {
        case header
        case cell(Int)
        
        var stringValue: String {
            return "\(self)"
        }
    }
    
    typealias CacheTypeLayoutDictionary = [CacheKey: UICollectionViewLayoutAttributes]
    
    weak var delegate: ListLayoutDelegate?
    
    private var cache: CacheTypeLayoutDictionary = CacheTypeLayoutDictionary()
    private var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0
    private var isNewData: Bool = false
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView,
              let delegate = delegate else {
            return
        }
        
        let numberOfItems: Int = collectionView.numberOfItems(inSection: 0)
        
        isNewData = numberOfItems <= PhotoUseCase.ParamConstants.perPage
        
        if isNewData {
            cache.removeAll(keepingCapacity: true)
            contentWidth = 0
            contentHeight = 0
        }
        
        let dataSourceType = (collectionView.dataSource as? ListLayoutCollectionViewFactory)?.dataSourceType ?? .list
        let photoWidth: CGFloat = collectionView.bounds.width
        
        var xOffset: CGFloat = contentWidth
        var yOffset: CGFloat = contentHeight
        
        if cache[.header] == nil && dataSourceType == .list {
            let headerSize: CGSize = CGSize(width: photoWidth,
                                            height: photoWidth)
            let kind: String = UICollectionView.elementKindSectionHeader
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind,
                                                                    with: IndexPath(item: 0, section: 0))
            headerAttributes.zIndex = 10
            headerAttributes.frame = CGRect(origin: .zero, size: headerSize)
            cache.updateValue(headerAttributes, forKey: .header)
            yOffset = photoWidth
        }
        
        let cellCacheListCount: Int = cache.filter({ $0.key.stringValue != "header" }).count
        
        for item in cellCacheListCount..<numberOfItems {
            let indexPath: IndexPath = IndexPath(item: item, section: 0)
            
            let photoHeight: CGFloat = delegate.collectionView(collectionView,
                                                               photoHeightForItemAt: indexPath)
            if scrollDirection == .horizontal {
                let centerYOffsetByMaxY: CGFloat = (collectionView.frame.maxY-photoHeight)/2
                yOffset = centerYOffsetByMaxY - collectionView.frame.minY
            }
            
            let frame: CGRect = CGRect(x: xOffset, y: yOffset,
                                       width: photoWidth, height: photoHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.updateValue(attributes, forKey: .cell(item))
            
            switch dataSourceType {
            case .list, .search:
                contentHeight = frame.maxY
                yOffset = yOffset + photoHeight
            case .detail:
                contentWidth = frame.maxX
                xOffset = xOffset + photoWidth
                yOffset = 0
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        self.visibleLayoutAttributes.removeAll(keepingCapacity: true)
        
        if cache[.header] != nil,
           let layoutAttributes = super.layoutAttributesForElements(in: rect),
           let offset = collectionView?.contentOffset {
            self.visibleLayoutAttributes = layoutAttributes
            if offset.y < 0 {
                for attributes in self.visibleLayoutAttributes {
                    if let kind = attributes.representedElementKind,
                       kind == UICollectionView.elementKindSectionHeader {
                        let diffValue = abs(offset.y)
                        var frame = attributes.frame
                        frame.size.height = max(0, headerReferenceSize.height + diffValue)
                        frame.origin.y = frame.minY - diffValue
                        attributes.frame = frame
                    }
                }
            }
        }
        
        var _first: Int?
        let range: Range<Int> = 0..<cache.count
        
        self.findFirstIndex(rect, range: range) { (first) in
            _first = first
        }
        self.findLastIndex(rect, range: range) { (last) in
            if let first = _first {
                self.setupAttributes(first: first, last: last)
            }
        }
        
        return self.visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[.cell(indexPath.item)]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return cache[.header]
        default:
            return nil
        }
    }
    
}

// Binary Search algorithm For Setup layoutAttributes
extension ListLayout {
    private func findFirstIndex(_ rect: CGRect,
                                range: Range<Int>,
                                completion: @escaping (Int) -> ()) {
        var firstFrameIndex: Int = 0
        
        for index in range {
            if rect.intersects(self.frameByCachedLayoutAttribute(index)) {
                firstFrameIndex = index
                completion(firstFrameIndex)
                break
            }
        }
    }
    
    private func findLastIndex(_ rect: CGRect,
                               range: Range<Int>,
                               completion: @escaping (Int) -> ()) {
        var lastFrameIndex: Int = cache.count
        
        for index in range.reversed() {
            if rect.intersects(self.frameByCachedLayoutAttribute(index)) {
                lastFrameIndex = min((index + 1), self.cache.count)
                completion(lastFrameIndex)
                break
            }
        }
    }
    
    private func setupAttributes(first: Int,
                                 last: Int) {
        for index in first..<last {
            let key = CacheKey.cell(index)
            if let attr = self.cache[key] {
                self.visibleLayoutAttributes.append(attr)
            }
        }
    }
    
    private func frameByCachedLayoutAttribute(_ index: Int) -> CGRect {
        return cache[.cell(index)]?.frame ?? .zero
    }
}
