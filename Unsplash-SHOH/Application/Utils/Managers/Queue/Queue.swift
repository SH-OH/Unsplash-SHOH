//
//  Queue.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/25.
//

import Foundation

enum Queue {
    case root
    case request
    case image(_ urlString: String)
    case cache
    
    var queue: DispatchQueue {
        switch self {
        case .root:
            return DispatchQueue(label: "queue.Unsplash-SHOH.root")
        case .request:
            return DispatchQueue(label: "queue.NetworkManager.request")
            
            // operationQueue로 바꿔서 해보자!
        case .image(let urlString):
            return DispatchQueue(label: "queue.NetworkManager.image.\(urlString)",
                                 attributes: .concurrent)
        case .cache:
            return DispatchQueue(label: "queue.ImageCahe.process")
        }
    }
}
