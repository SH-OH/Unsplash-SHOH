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
        // Do any additional setup after loading the view.
//        NetworkManager.shared.request(String.self, urlString: "", method: <#T##NetworkManager.HTTPMethod#>, completion: <#T##(Result<Data?, Error>) -> ()#>)
        
        
        let findUrl = Bundle.main.url(forResource: "UserJson", withExtension: "json")!
        let makeData = try! Data(contentsOf: findUrl)
        let makeJson = try! JSONDecoder().decode(PhotoUser.self, from: makeData)
        print(makeJson)
    }


}

