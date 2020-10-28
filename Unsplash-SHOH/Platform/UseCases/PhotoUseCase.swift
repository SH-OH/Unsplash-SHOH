//
//  PhotoUseCase.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/24.
//

import UIKit.UIViewController

struct PhotoUseCase {
    
    enum ParamConstants {
        static let perPage: Int = 30
        static let orderBy: OrderBy = .relevant
        static let contentFilter: ContentFilter = .high
        
        enum OrderBy: String {
            case relevant, latest
        }
        enum ContentFilter: String {
            case low, high
        }
    }
    
    private let provider: Provider = .init()
    
    func getPhotoList(oldModels: [PhotoModel],
                      completion: @escaping ([PhotoModel]) -> ()) {
        let page: Int = self.compareModelCountToPerPage(oldModels.count,
                                                        ParamConstants.perPage)
        guard page > 0 else { return }
        let params: [String: Any] = [
            "page": page,
            "per_page": ParamConstants.perPage
        ]
        provider.request([PhotoModel].self,
                          urlString: APIDomain.photos.url,
                          method: .get,
                          parameters: params) { (result) in
            if case let .success(newModels) = result {
                let result: [PhotoModel] = oldModels + newModels
                completion(result)
            }
        }
    }
    
    func getSearchList(_ searchedText: String,
                       isChanged: Bool,
                       oldModels: [PhotoModel],
                       completion: @escaping ([PhotoModel]) -> ()) {
        let page: Int = isChanged
            ? 1
            : self.compareModelCountToPerPage(oldModels.count, ParamConstants.perPage)
         let params: [String: Any] = [
            "query": searchedText,
            "page": page,
            "per_page": ParamConstants.perPage,
            "order_by": ParamConstants.orderBy.rawValue,
            "content_filter": ParamConstants.contentFilter.rawValue
        ]
        provider.request(PhotoSearch.self,
                         urlString: APIDomain.search.url,
                         method: .get,
                         parameters: params) { (result) in
            if case let .success(result) = result {
                let prevModels = isChanged
                    ? []
                    : oldModels
                let result: [PhotoModel] = prevModels + result.results
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
