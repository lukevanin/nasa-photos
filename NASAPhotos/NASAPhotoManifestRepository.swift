//
//  MediaAssetRepository.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation
import Combine


///
///
///
protocol AssetManifestRepositoryProtocol {
    func fetchManifest(for url: URL) -> AnyPublisher<MediaAssetManifestEntity, Error>
}


///
/// Provides asset manifests for photos. An asset manifest is the list of resources associated with a photo,
/// such the URLs of the available images.
///
final class NASAPhotoManifestRepository: AssetManifestRepositoryProtocol {
    
    private let service: CodableGetService
    
    init(service: CodableGetService) {
        self.service = service
    }
    
    func fetchManifest(for url: URL) -> AnyPublisher<MediaAssetManifestEntity, Error> {
        service
            .get(MediaAssetManifestEntity.self, url: url)
            .eraseToAnyPublisher()
    }
}
