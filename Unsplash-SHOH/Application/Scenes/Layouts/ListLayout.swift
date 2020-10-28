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
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView,
              let delegate = delegate else {
            return
        }
        
        let numberOfItems: Int = collectionView.numberOfItems(inSection: 0)
        // 1. 리스트 불러올 때마다 item과 cache 갯수 비교하여(>) 레이아웃 prepare.
        guard numberOfItems > cache.count else {
            return
        }
        
        let dataSourceType = (collectionView.dataSource as? ListLayoutCollectionViewFactory)?.findDataSourceType() ?? .list
        let photoWidth: CGFloat = collectionView.bounds.width
        
        /// more 시 바로 offset에 + 하기 위해, offset start value를 현재 collectionView의 size로 설정.
        var xOffset: CGFloat = contentWidth
        var yOffset: CGFloat = contentHeight
        
        // 메인 섹션 헤더 layoutAttributes 만들기.
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
        
        // 2. Cell 리스트 중에서, 추가된 item만 layoutAttributes 만들기.
        let cellCacheListCount: Int = cache.filter({ $0.key.stringValue != "header" }).count
        
        for item in cellCacheListCount..<numberOfItems {
            let indexPath: IndexPath = IndexPath(item: item, section: 0)
            
            // 2-1. 사진 resize된 height로 셀 frame 만들기.
            let photoHeight: CGFloat = delegate.collectionView(collectionView,
                                                               photoHeightForItemAt: indexPath)
            // 2-1-1. Horizontal 대상, 이미지 가운데 정렬. (상세 화면)
            if scrollDirection == .horizontal {
                let centerYOffsetByMaxY: CGFloat = (collectionView.frame.maxY-photoHeight)/2
                yOffset = centerYOffsetByMaxY - collectionView.frame.minY
            }
            
            let frame: CGRect = CGRect(x: xOffset, y: yOffset,
                                       width: photoWidth, height: photoHeight)
            
            // 2-2. IndexPath Key Type의 Dictionary Cache에 Attributes 만들어서 저장.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.updateValue(attributes, forKey: .cell(item))
            
            // 2-3. 위에서 구한 cell frame으로 CollectionView total Offset(for contentsSize) 구하기.
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
        
        // 0. 헤더 속성 추가
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
        
        // cache에서 바로 rect와 frame 겹치는 속성들 비교해서 가져오려하니, 아이템이 많을때 스크롤 빠르게 내리면 레이아웃 찾는게 느림..
        // 이진탐색으로 개선 처리.
        
        var _first: Int?
        var _last: Int?
        let range: Range<Int> = 0..<cache.count
        
        self.findFirstIndex(rect, range: range) { (first) in
            if let last = _last {
                self.setupAttributes(first: first, last: last)
            }
            _first = first
        }
        self.findLastIndex(rect, range: range) { (last) in
            if let first = _first {
                self.setupAttributes(first: first, last: last)
            }
            _last = last
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
    
    private func frameByCachedLayoutAttribute(_ index: Int) -> CGRect {
        return cache[.cell(index)]?.frame ?? .zero
    }
}

// Binary Search algorithm For Setup layoutAttributes
extension ListLayout {
    private func findFirstIndex(_ rect: CGRect,
                                range: Range<Int>,
                                completion: @escaping (Int) -> ()) {
        var firstFrameIndex: Int = 0
        
        // 1. 처음부터 검색, 보여줄 아이템 중 맨 앞의 index 가져옴.
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
        
        // 2. 마지막부터 검색, 보여줄 아이템 중 맨 뒤의 index 가져옴.
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
        // 3. 재계산된 index들로 visible item들의 속성 모두 추가함.
        for index in first..<last {
            let key = CacheKey.cell(index)
            if let attr = self.cache[key] {
                self.visibleLayoutAttributes.append(attr)
            }
        }
    }
    
}
