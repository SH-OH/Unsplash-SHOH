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
    case cache(_ get: Bool)
    
    var queue: DispatchQueue {
        switch self {
        case .request:
            return DispatchQueue(label: "queue.NetworkManager.request")
        case .image(let urlString):
            return DispatchQueue(label: "queue.NetworkManager.image.\(urlString)",
                                 attributes: .concurrent)
        case .cache(let get):
            let getSet = get ? "getImage" : "setImage"
            return DispatchQueue(label: "queue.ImageCahe.\(getSet)")
        }
    }
}
