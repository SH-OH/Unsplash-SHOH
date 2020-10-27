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
    let exif: PhotoExif?
    let user: PhotoUser?
    let urls: [URLType: URL]
    let links: [LinkType: URL]
    let likes: Int
    let downloads: Int?
    let views: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id, height, width, color, exif, user, urls, links, likes, downloads, views
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        height = try container.decode(Int.self, forKey: .height)
        width = try container.decode(Int.self, forKey: .width)
        color = try container.decode(UIColor.self, forKey: .color)
        exif = try? container.decode(PhotoExif.self, forKey: .exif)
        user = try container.decode(PhotoUser.self, forKey: .user)
        urls = try container.decode([URLType: URL].self, forKey: .urls)
        links = try container.decode([LinkType: URL].self, forKey: .links)
        likes = try container.decode(Int.self, forKey: .likes)
        downloads = try? container.decode(Int.self, forKey: .downloads)
        views = try? container.decode(Int.self, forKey: .views)
    }
}
