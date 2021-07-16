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

extension PhotoManifest {
    private static let variantNames: [String : Variant] = [
        "small": .small,
        "medium": .medium,
        "orig": .original,
        "thumb": .thumbnail,
    ]
    
    init(urls: [URL]) {
        var assets = [Variant : URL]()
        for url in urls {
            guard let variant = Self.variant(for: url.path) else {
                continue
            }
            assets[variant] = url
        }
        self.assets = assets
    }
    
    static func variant(for path: String) -> Variant? {
        let components = path.split(separator: "~")
        guard components.count == 2 else {
            return nil
        }
        let suffixes = components[1].split(separator: ".")
        guard suffixes.count == 2 else {
            return nil
        }
        let name = String(suffixes[0])
        let variant = variantNames[name]
        return variant
    }
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
