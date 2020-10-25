//
//  PhotoUseCase.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UIViewController

struct PhotoUseCase {
    
    private let provider: Provider
    
    init(_ parentController: UIViewController) {
        self.provider = Provider(parentController)
    }
    
    func getPhotoList(oldModels: [PhotoModel],
                      completion: @escaping ([PhotoModel]) -> ()) {
        Log.osh("oldModel : \(oldModels)")
        let perPage: Int = 30
        let page: Int = self.compareModelCountToPerPage(oldModels.count,
                                                        perPage)
        guard page > 0 else { return }
        let params: [String: Any] = [
            "page": page,
            "per_page": perPage
        ]
        provider.request([PhotoModel].self,
                          urlString: APIDomain.photos.url,
                          method: .get,
                          parameters: params,
                          useLoading: false) { (result) in
            if case let .success(newModels) = result {
                let result: [PhotoModel] = oldModels + newModels
                completion(result)
            }
        }
    }
    
    private func compareModelCountToPerPage(_ oldModels: Int,
                                            _ perPage: Int) -> Int {
        var page: Int = oldModels/perPage
        switch oldModels {
        case 0:
            page = 1
        case 1..<perPage:
            return 0
        default:
            page += 1
        }
        return page
    }
}
