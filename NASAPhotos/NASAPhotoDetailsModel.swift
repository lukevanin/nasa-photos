//
//  NASAPhotoDetailsModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation
import Combine


///
/// Provides details for a specific photo provided by the NASA images API. Provides the preview image from
/// the asset manifest.
///
final class NASAPhotoDetailsModel: PhotoDetailsModelProtocol {
    
    typealias Photo = NASAPhoto
    
    enum Variant {
        case small
        case medium
        case original
        case thumbnail
    }

    let photo: CurrentValueSubject<NASAPhoto, Never>
    let error = PassthroughSubject<Error, Never>()

    private var manifestCancellable: AnyCancellable?
    private let manifestRepository: AssetManifestRepositoryProtocol
    
    private let previewImageVariants: [Variant]
    private let originalPhoto: Photo
    
    init(
        photo: NASAPhoto,
        previewImageVariants: [Variant] = [
            .small,
            .medium,
            .original,
            .thumbnail,
        ],
        manifestRepository: AssetManifestRepositoryProtocol
    ) {
        self.originalPhoto = photo
        self.photo = CurrentValueSubject(photo)
        self.previewImageVariants = previewImageVariants
        self.manifestRepository = manifestRepository
    }
    
    func reload() {
        guard let manifestURL = originalPhoto.manifestURL else {
            error.send(URLError(.resourceUnavailable))
            return
        }
        manifestCancellable = manifestRepository
            .fetchManifest(for: manifestURL)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return
                    }
                    switch completion {
                    case .failure(let error):
                        self.error.send(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] manifest in
                    guard let self = self else {
                        return
                    }
                    let photo = self.makePhoto(with: manifest)
                    self.photo.send(photo)
                }
            )
    }
    
    private func makePhoto(with manifest: MediaAssetManifestEntity) -> NASAPhoto {
        var output = originalPhoto
        output.previewImageURL = previewImageURL(for: manifest)
        return output
    }
    
    private func previewImageURL(for manifest: MediaAssetManifestEntity) -> URL? {
        let urls = manifest.map { $0.url }
        let assets = makeVariants(from: urls)
        for variant in previewImageVariants {
            if let url = assets[variant] {
                return url
            }
        }
        return nil
    }

    private func makeVariants(from urls: [URL]) -> [Variant : URL] {
        var assets = [Variant : URL]()
        for url in urls {
            guard let variant = self.variant(for: url.path) else {
                continue
            }
            assets[variant] = url
        }
        return assets
    }
    
    private let variantNames: [String : Variant] = [
        "small": .small,
        "medium": .medium,
        "orig": .original,
        "thumb": .thumbnail,
    ]

    private func variant(for path: String) -> Variant? {
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
