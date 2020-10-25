//
//  Provider.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation
import UIKit

final class Provider {
    
    enum Result<Decodable, Error> {
        case success(Decodable)
        case failure(Error)
    }
    
    var task: URLSessionDataTask?
    
    private let parentController: UIViewController
    
    init(_ parentController: UIViewController) {
        self.parentController = parentController
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
    
    private func prepareURLRequest(_ url: URL, method: NetworkManager.HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url,
                                 timeoutInterval: NetworkManager.shared.timeout)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = APIDomain.header
        return request
    }
    
    func request<T: Decodable>(_ type: T.Type,
                               urlString: String,
                               method: NetworkManager.HTTPMethod,
                               parameters: [String: Any]?,
                               useLoading: Bool,
                               completion: @escaping (Result<T, Error>) -> ()) {
        guard task == nil else {
            return
        }
        guard let components = self.prepareURLComponenets(urlString, parameters: parameters) else {
            return completion(.failure(NetworkManager.RequestError.invalidURL))
        }
        guard let url: URL = components.url ?? URL(string: urlString) else {
            return completion(.failure(NetworkManager.RequestError.invalidURL))
        }
        let request: URLRequest = self.prepareURLRequest(url, method: method)
        NetworkManager.shared.showNetworkActivity(self.parentController,
                                                  show: true,
                                                  useLoading: useLoading)
        task = NetworkManager.shared.session.dataTask(with: request) { (data, response, error) in
            NetworkManager.shared.showNetworkActivity(self.parentController,
                                                      show: false,
                                                      useLoading: useLoading)
            Queue.request.queue.async {
                #if DEBUG
                let response: String = String(data: data ?? .init(), encoding: .utf8) ?? "NO DATA"
                let makeDict: [String: Any] = [
                    "01.URL": "[\(method)] \(url)",
                    "02.parameters": parameters ?? "NO PARAMETERS",
                    "03.Response": response.isEmpty ? "NO DATA" : response
                ]
                //                Log.d(makeDict)
                #endif
                if let error = error {
                    Log.e(error)
                    return completion(.failure(error))
                }
                if let data = data,
                   let makeJson: T = try? T.decode(data: data) {
                    //                    Log.osh("success json : \(makeJson)")
                    return completion(.success(makeJson))
                } else {
                    return completion(.failure(NetworkManager.RequestError.failedParsing))
                }
            }
        }
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}
