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
        for i in 0...10 {
            print("0. for in : \(i)")
            NetworkManager.shared.request(PhotoModel.self,
                                          index: i,
                                          urlString: APIDomain.photos.url,
                                          method: .get,
                                          parameters: params) { (result) in
                print("5. result : \(i)")
            }
        }
        
    }

}

