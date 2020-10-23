//
//  ViewModelType.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
