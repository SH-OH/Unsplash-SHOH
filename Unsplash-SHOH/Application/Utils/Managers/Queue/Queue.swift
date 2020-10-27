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
    case image
    case cache
    
    var queue: DispatchQueue {
        switch self {
        case .root:
            return DispatchQueue(label: "queue.Unsplash-SHOH.root")
        case .request:
            return DispatchQueue(label: "queue.NetworkManager.request")
        case .image:
            return DispatchQueue(label: "queue.NetworkManager.image.download",
                                 attributes: .concurrent)
        case .cache:
            return DispatchQueue(label: "queue.ImageCahe.process")
        }
    }
}
