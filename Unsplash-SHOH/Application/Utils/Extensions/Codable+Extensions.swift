//
//  Codable+Extensions.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation

extension Encodable {
    func encode(_ encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
}

extension Decodable {
    static func decode(_ decoder: JSONDecoder = JSONDecoder(), data: Data) throws -> Self {
        return try decoder.decode(self, from: data)
    }
}
