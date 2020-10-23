//
//  NetworkManager.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import Foundation
import UIKit

final class NetworkManager {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum RequestError: Error {
        case invalidURL
        case failedParsing
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .failedParsing:
                return "Failed Parsing to jsonData"
            }
        }
    }
    
    enum Queue {
        case request
        case image(String)
        
        var queue: DispatchQueue {
            switch self {
            case .request:
                return DispatchQueue(label: "queue.NetworkManager.request")
            case .image(let urlString):
                return DispatchQueue(label: "queue.NetworkManager.image.\(urlString)")
            }
        }
    }
    
    var timeout: Double = 20.0
    
    static let shared = NetworkManager()
    
    private(set) var session: URLSession
    private let loadingView: LoadingViewController
    
    private init() {
        self.session = .shared
        self.loadingView = LoadingViewController()
    }
    
}

// MARK: - NetworkActivity
extension NetworkManager {
    func showNetworkActivity(_ show: Bool, useLoading: Bool) {
        guard useLoading else { return }
        loadingView.control(show: show, useLoading: useLoading)
    }
}
