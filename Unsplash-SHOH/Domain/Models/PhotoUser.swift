//
//  PhotoUser.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import Foundation

struct PhotoUser: Decodable {
    enum ProfileImageSize: String, Decodable {
        case small, medium, large
    }
    enum LinkType: String, Decodable {
        case `self`, html, photos, likes, portfolio
    }
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let name: String?
    let profileImage: [ProfileImageSize: URL]
    let bio: String?
    let links: [LinkType: URL]
    let location: String?
    let portfolioURL: URL?
    let totalCollections: Int
    let totalLikes: Int
    let totalPhotos: Int
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
        case portfolioURL = "portfolio_url"
        case totalCollections = "total_collections"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case id, username, name, bio, links, location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        firstName = try? container.decode(String.self, forKey: .firstName)
        lastName = try? container.decode(String.self, forKey: .lastName)
        name = try? container.decode(String.self, forKey: .name)
        profileImage = try container.decode([ProfileImageSize: URL].self, forKey: .profileImage)
        bio = try? container.decode(String.self, forKey: .bio)
        links = try container.decode([LinkType: URL].self, forKey: .links)
        location = try? container.decode(String.self, forKey: .location)
        portfolioURL = try? container.decode(URL.self, forKey: .portfolioURL)
        totalCollections = try container.decode(Int.self, forKey: .totalCollections)
        totalLikes = try container.decode(Int.self, forKey: .totalLikes)
        totalPhotos = try container.decode(Int.self, forKey: .totalPhotos)
    }
}
