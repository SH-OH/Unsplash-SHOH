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
        testRetrieveImage()
    }
    
    private func testRetrieveImage() {
        let urlString = "https://images.unsplash.com/photo-1602524821041-4ca34980d066?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max&ixid=eyJhcHBfaWQiOjE3NjQ4N30"
        let url = URL(string: urlString)!
        let downloader = ImageDownloader()
        downloader.retriveImage(url) { (image) in
            Log.osh(image)
            Log.osh("==================================================")
            for _ in 0...100 {
                downloader.retriveImage(url) { (image) in
                    Log.osh(image)
                }
            }
        }
        
    }
    
    private func testRequest() {
        let params: [String: Any] = [
            "page": 1,
            "per_page": 10
        ]
        for _ in 0...10 {
            DataRequester().request([PhotoModel].self,
                                          urlString: APIDomain.photos.url,
                                          method: .get,
                                          parameters: params,
                                          useLoading: true) { (result) in
                if case let .success(model) = result {
                    
                }
            }
        }
    }

}

