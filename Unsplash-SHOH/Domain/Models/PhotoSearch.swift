//
//  PhotoSearch.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import Foundation

struct PhotoSearch: Decodable {
    let total: Int
    let totalPages: Int
    let results: [PhotoModel]
    
    private enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case total, results
    }
}
