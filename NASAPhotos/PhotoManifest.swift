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
struct PhotoManifestBuilder {

    func makePhotoManifest(from urls: [URL]) -> PhotoManifest {
        var assets = [PhotoManifest.Variant : URL]()
        for url in urls {
            guard let variant = self.variant(for: url.path) else {
                continue
            }
            assets[variant] = url
        }
        return PhotoManifest(assets: assets)
    }
    
    private let variantNames: [String : PhotoManifest.Variant] = [
        "small": .small,
        "medium": .medium,
        "orig": .original,
        "thumb": .thumbnail,
    ]

    private func variant(for path: String) -> PhotoManifest.Variant? {
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
