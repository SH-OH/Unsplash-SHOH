//
//  Queue.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import Foundation

enum Queue {
    case request
    case image(_ urlString: String)
    case cache
    
    var queue: DispatchQueue {
        switch self {
        case .request:
            return DispatchQueue(label: "queue.NetworkManager.request")
        case .image(let urlString):
            return DispatchQueue(label: "queue.NetworkManager.image.\(urlString)",
                                 attributes: .concurrent)
        case .cache:
            return DispatchQueue(label: "queue.ImageCahe.process")
        }
    }
}
