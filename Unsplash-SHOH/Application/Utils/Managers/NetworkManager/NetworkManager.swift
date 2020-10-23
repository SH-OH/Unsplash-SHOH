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
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            }
        }
    }
    
    enum Queue {
        static let rootQueue: DispatchQueue = DispatchQueue(label: "queue.NetworkManager.root",
                                                            qos: .background)
        static let requestQueue: DispatchQueue = DispatchQueue(label: "\(Queue.rootQueue).request",
                                                               qos: .utility,
                                                               target: Queue.rootQueue)
        static let imageQueue: DispatchQueue = DispatchQueue(label: "\(Queue.rootQueue).image",
                                                             qos: .utility,
                                                             target: Queue.rootQueue)
    }
    
    var timeout: Double = 20.0
    
    static let shared = NetworkManager()
    
    private(set) var session: URLSession
    
    private init() {
        self.session = .shared
    }
    
    private func prepareURLRequest(_ url: URL, method: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url,
                                 timeoutInterval: self.timeout)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = APIDomain.header
        return request
    }
    
    private func prepareURLComponenets(_ urlString: String,
                                    parameters: [String: Any]?) -> URLComponents? {
        var components = URLComponents(string: urlString)
        
        if let parameters = parameters {
            var makeParameters = [URLQueryItem]()
            for (name, value) in parameters {
                if name.isEmpty { continue }
                let makeItem = URLQueryItem(name: name, value: "\(value)")
                makeParameters.append(makeItem)
            }
            components?.queryItems = makeParameters
        }
        return components
    }
    
}

extension NetworkManager {
    
    enum Result<Decodable, Error> {
        case success(Decodable)
        case failure(Error)
    }
    
    func request<T: Decodable>(_ type: T.Type,
                               index: Int,
                               urlString: String,
                               method: HTTPMethod,
                               parameters: [String: Any]?,
                               callbackQueue: DispatchQueue = Queue.requestQueue,
                               completion: @escaping (Result<T, Error>) -> ()) {
        guard let components = self.prepareURLComponenets(urlString, parameters: parameters) else {
            return completion(.failure(RequestError.invalidURL))
        }
        guard let url: URL = components.url ?? URL(string: urlString) else {
            return completion(.failure(RequestError.invalidURL))
        }
        let request: URLRequest = self.prepareURLRequest(url, method: method)
        print("1. root in before : \(index)")
        Queue.rootQueue.async {
            print("2. root in after : \(index)")
            self.showNetworkActivity(true)
            let newTask: URLSessionDataTask = self.session.dataTask(with: request) { [weak self] (data, response, error) in
                self?.showNetworkActivity(false)
                print("3. request in before : \(index)")
                Queue.requestQueue.sync {
                    print("4. request in after : \(index)")
                    #if DEBUG
                    let response: String = String(data: data ?? .init(), encoding: .utf8) ?? "NO DATA"
                    let makeDict: [String: Any] = [
                        "01.URL": "[\(method)] \(url)",
                        "02.parameters": parameters ?? "NO PARAMETERS",
                        "03.Response": response.isEmpty ? "NO DATA" : response
                    ]
//                    Log.d(makeDict)
                    #endif
                    if let error = error {
//                        Log.e(error)
                        return completion(.failure(error))
                    }
                    if let data = data,
                       let makeJson: T = try? T.decode(data: data) {
//                        print("success json : \(makeJson)")
                        return completion(.success(makeJson))
                    }
                }
            }
            newTask.resume()
        }
    }
}

extension NetworkManager {
    private func showNetworkActivity(_ show: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = show
        }
    }
}
