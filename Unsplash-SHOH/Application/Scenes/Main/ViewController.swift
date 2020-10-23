//
//  ViewController.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let params: [String: Any] = [
            "page": 1,
            "per_page": 10
        ]
        NetworkManager.shared.request(String.self,
                                      urlString: APIDomain.photos.url,
                                      method: .get,
                                      parameters: params) { (result) in
            if case let .success(data) = result {
                guard let data = data else { return }
                let makeJson = try! JSONDecoder().decode([PhotoModel].self, from: data)
                Log.osh("success json : \(makeJson)")
            }
        }
    }

}

