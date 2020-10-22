//
//  PhotoExif.swift
//  Unsplash-SHOH
//
//  Created by Oh Sangho on 2020/10/22.
//

import Foundation

struct PhotoExif: Decodable {
    let make: String
    let model: String
    let exposureTime: String
    let aperture: String
    let focalLength: String
    let iso: String
    
    
    private enum CodingKeys: String, CodingKey {
        case exposureTime = "exposure_time"
        case focalLength = "focal_length"
        case make, model, aperture, iso
    }
}
