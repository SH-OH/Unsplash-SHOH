//
//  PhotoModel.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import UIKit

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
    
}
