//
//  ListLayout.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UICollectionViewLayout

protocol ListLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath:IndexPath) -> CGFloat
}

final class ListLayout: UICollectionViewFlowLayout {
    
    typealias CacheTypeLayoutDictionary = [IndexPath: UICollectionViewLayoutAttributes]
    
    weak var delegate: ListLayoutDelegate?
    
    private var cache = CacheTypeLayoutDictionary()
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.bounds.width
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
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
        
        let columnWidth: CGFloat = contentWidth
        /// more 시 바로 y에 + 하기 위해, yOffset start value를 현재 collectionView의 최대 높이로 설정.
        var yOffset: CGFloat = contentHeight
        
        // 2. 추가된 item만 layoutAttributes 만들기.
        for item in cache.count..<numberOfItems {
            let indexPath: IndexPath = IndexPath(item: item, section: 0)
            
            // 2-1. 사진 height 가져와서 셀 frame 만들기.
            let photoHeight: CGFloat = delegate.collectionView(collectionView, heightForItemAt: indexPath)
            let frame = CGRect(x: 0, y: yOffset, width: columnWidth, height: photoHeight)
            
            // 2-2. IndexPath Key Type의 Dictionary Cache에 Attributes 만들어서 저장.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.updateValue(attributes, forKey: indexPath)
            
            // 2-3. 위에서 구한 cell frame의 maxY로 CollectionView total height(for contentsSize) 구하기.
            contentHeight = frame.maxY
            yOffset = yOffset + photoHeight
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // cache에서 바로 rect와 frame 겹치는 속성들 비교해서 가져오려하니, 아이템이 많을때 스크롤 빠르게 내리면 레이아웃 찾는게 느림..
        // 이진탐색으로 개선 처리.
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        var firstFrameIndex: Int = 0
        var lastFrameIndex: Int = cache.count
        let range: Range<Int> = 0..<lastFrameIndex
        
        // 1. 처음부터 검색, 보여줄 아이템 중 맨 앞의 index 가져옴.
        for index in range {
            if rect.intersects(self.frameByCachedLayoutAttribute(index)) {
                firstFrameIndex = index
                break
            }
        }
        
        // 2. 마지막부터 검색, 보여줄 아이템 중 맨 뒤의 index 가져옴.
        for index in range.reversed() {
            if rect.intersects(self.frameByCachedLayoutAttribute(index)) {
                lastFrameIndex = min((index + 1), self.cache.count)
                break
            }
        }
        
        // 3. 재계산된 index들로 visible item들의 속성 모두 추가함.
        for index in firstFrameIndex..<lastFrameIndex {
            if let attr = self.cache[IndexPath(item: index, section: 0)] {
                visibleLayoutAttributes.append(attr)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print(#function)
        return cache[indexPath]
    }
    
    private func frameByCachedLayoutAttribute(_ index: Int) -> CGRect {
        return cache[IndexPath(item: index, section: 0)]?.frame ?? .zero
    }
    
}
