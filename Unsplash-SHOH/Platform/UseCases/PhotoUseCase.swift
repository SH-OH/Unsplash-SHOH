//
//  PhotoUseCase.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import Foundation

struct PhotoUseCase {
    var provider: Provider = Provider()
    func getPhotoList(_ page: Int,
                      oldModels: [PhotoModel],
                      completion: @escaping ([PhotoModel]) -> ()) {
        let params: [String: Any] = [
            "page": page,
            "per_page": 40
        ]
        provider.request([PhotoModel].self,
                          urlString: APIDomain.photos.url,
                          method: .get,
                          parameters: params,
                          useLoading: true) { (result) in
            if case let .success(newModels) = result {
                let result: [PhotoModel] = oldModels + newModels
                completion(result)
            }
        }
    }
}
