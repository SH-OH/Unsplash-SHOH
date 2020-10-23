//
//  Array+Extensions.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}
