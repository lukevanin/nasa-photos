//
//  PhotoManifestBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import Foundation


///
/// Creates a manifest that lists of available asets and their relative sizes, given a list of asset URLs.
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
