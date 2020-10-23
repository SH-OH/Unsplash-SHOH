//
//  Cell+Extensions.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UITableViewCell
import UIKit.UICollectionViewCell

extension UITableView {
    final func register<Cell: UITableViewCell>(_ cellType: Cell.Type) {
        self.register(cellType.self,
                      forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func dequeue<Cell: UITableViewCell>(_ cellType: Cell.Type = Cell.self, for ip: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: ip) as? Cell else {
            preconditionFailure("\(cellType)의 재사용 셀 생성 실패")
        }
        return cell
    }
}

extension UICollectionView {
    final func register<Cell: UICollectionViewCell>(_ cellType: Cell.Type) {
        self.register(cellType.self,
                      forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func dequeue<Cell: UICollectionViewCell>(_ cellType: Cell.Type = Cell.self, for ip: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: ip) as? Cell else {
            preconditionFailure("\(cellType)의 재사용 셀 생성 실패")
        }
        return cell
    }
    final func dequeue<View: UICollectionReusableView>(_ cellType: View.Type = View.self,
                                                       kind: String,
                                                       for ip: IndexPath) -> View {
        guard let headerView = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cellType.reuseIdentifier, for: ip) as? View else {
            preconditionFailure("\(cellType)의 재사용 뷰 생성 실패")
        }
        return headerView
    }
}

extension UITableViewCell: Reusable {}
extension UICollectionReusableView: Reusable {}
