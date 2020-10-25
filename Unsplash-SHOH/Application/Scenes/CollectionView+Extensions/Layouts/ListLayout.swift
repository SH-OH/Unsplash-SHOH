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
    
    typealias CacheTypeLayoutDictionary = [IndexPath: UICollectionViewLayoutAttributes]
    
    weak var delegate: ListLayoutDelegate?
    
    private var cache = CacheTypeLayoutDictionary()
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat = 0
    
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
        
        /// more 시 바로 offset에 + 하기 위해, offset start value를 현재 collectionView의 size로 설정.
        var xOffset: CGFloat = contentWidth
        var yOffset: CGFloat = contentHeight
        
        let photoWidth: CGFloat = collectionView.bounds.width
        
        // 2. 추가된 item만 layoutAttributes 만들기.
        for item in cache.count..<numberOfItems {
            let indexPath: IndexPath = IndexPath(item: item, section: 0)
            
            // 2-1. 사진 resize된 height로 셀 frame 만들기.
            let photoHeight: CGFloat = delegate.collectionView(collectionView,
                                                               photoHeightForItemAt: indexPath)
            // 2-1-1. 상세 화면, 이미지 가운데 정렬.
            if scrollDirection == .horizontal {
                let centerYOffsetByMaxY: CGFloat = (collectionView.frame.maxY-photoHeight)/2
                yOffset = centerYOffsetByMaxY - collectionView.frame.minY
            }
            
            let frame: CGRect = CGRect(x: xOffset, y: yOffset,
                                       width: photoWidth, height: photoHeight)
            
            // 2-2. IndexPath Key Type의 Dictionary Cache에 Attributes 만들어서 저장.
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.updateValue(attributes, forKey: indexPath)
            
            // 2-3. 위에서 구한 cell frame으로 CollectionView total Offset(for contentsSize) 구하기.
            if scrollDirection == .vertical {
                contentHeight = frame.maxY
                yOffset = yOffset + photoHeight
            } else {
                contentWidth = frame.maxX
                xOffset = xOffset + photoWidth
                yOffset = 0
            }
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
