//
//  PhotoUser.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import Foundation

struct PhotoUser: Decodable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case id, username, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        firstName = try? container.decode(String.self, forKey: .firstName)
        lastName = try? container.decode(String.self, forKey: .lastName)
        name = try? container.decode(String.self, forKey: .name)
    }
}
