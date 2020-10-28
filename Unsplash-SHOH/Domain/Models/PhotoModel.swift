//
//  PhotoModel.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit.UIColor

struct PhotoModel: Decodable {
    enum URLType: String, Decodable {
        case raw, thumb, small, regular, full
    }
    
    enum LinkType: String, Decodable {
        case `self`, html, download, downloadLocation = "download_location"
    }
    
    let id: String
    let height: Int
    let width: Int
    let color: UIColor?
    let user: PhotoUser?
    let urls: [URLType: URL]
    
    private enum CodingKeys: String, CodingKey {
        case id, height, width, color, user, urls
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        height = try container.decode(Int.self, forKey: .height)
        width = try container.decode(Int.self, forKey: .width)
        color = try container.decode(UIColor.self, forKey: .color)
        user = try container.decode(PhotoUser.self, forKey: .user)
        urls = try container.decode([URLType: URL].self, forKey: .urls)
    }   
}
