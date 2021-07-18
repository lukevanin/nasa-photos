//
//  PhotoManifest.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation

///
///
///
struct PhotoManifest {
    enum Variant {
        case small
        case medium
        case original
        case thumbnail
    }
    
    let assets: [Variant : URL]
}

extension PhotoManifest: Equatable {
    
}

extension PhotoManifest {
    func firstURL(matching variants: [Variant]) -> URL? {
        for variant in variants {
            if let url = assets[variant] {
                return url
            }
        }
        return nil
    }
}
