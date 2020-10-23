//
//  KeyedDecodingContainer+Extensions.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/23.
//

import Foundation
import UIKit.UIColor

extension KeyedDecodingContainer {
    func decode(_ type: UIColor.Type,
                forKey key: Key) throws -> UIColor {
        let hexColor: String = try self.decode(String.self, forKey: key)
        return UIColor(hexString: hexColor)
    }
    
    func decode(_ type: [PhotoModel.URLType: URL].Type,
                forKey key: Key) throws -> [PhotoModel.URLType: URL] {
        let urlDic: [String: String] = try self.decode([String: String].self, forKey: key)
        var result: [PhotoModel.URLType: URL] = [:]
        for (key, value) in urlDic {
            if let type = PhotoModel.URLType(rawValue: key),
               let url = URL(string: value) {
                result[type] = url
            }
        }
        return result
    }

    func decode(_ type: [PhotoModel.LinkType: URL].Type,
                forKey key: Key) throws -> [PhotoModel.LinkType: URL] {
        let urlDic: [String: String] = try self.decode([String: String].self, forKey: key)
        var result: [PhotoModel.LinkType: URL] = [:]
        for (key, value) in urlDic {
            if let type = PhotoModel.LinkType(rawValue: key),
               let url = URL(string: value) {
                result[type] = url
            }
        }
        return result
    }
    
    func decode(_ type: [PhotoUser.ProfileImageSize: URL].Type,
                forKey key: Key) throws -> [PhotoUser.ProfileImageSize: URL] {
        let sizeDic: [String: String] = try self.decode([String: String].self, forKey: key)
        var result: [PhotoUser.ProfileImageSize: URL] = [:]
        for (key, value) in sizeDic {
            if let size = PhotoUser.ProfileImageSize(rawValue: key),
               let url = URL(string: value) {
                result[size] = url
            }
        }
        return result
    }
    
    func decode(_ type: [PhotoUser.LinkType: URL].Type,
                forKey key: Key) throws -> [PhotoUser.LinkType: URL] {
        let linkDic: [String: String] = try self.decode([String: String].self, forKey: key)
        var result: [PhotoUser.LinkType: URL] = [:]
        for (key, value) in linkDic {
            if let type = PhotoUser.LinkType(rawValue: key),
               let url = URL(string: value) {
                result[type] = url
            }
        }
        return result
    }
}
