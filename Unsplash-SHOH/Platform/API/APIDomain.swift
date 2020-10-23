//
//  APIDomain.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation

enum APIDomain {
    static let baseUrl: String = "https://api.unsplash.com"
    
    case photos
    case search
    
    var url: String {
        switch self {
        case .photos:
            return "\(APIDomain.baseUrl)/photos"
        case .search:
            return "\(APIDomain.baseUrl)/search/photos"
        }
    }
}

extension APIDomain {
    static let header: [String: String] = [
        "Accept-Version": "v1",
        "Authorization": "Client-ID \(AppConstants.ACCESS_KEY)"
    ]
}
