//
//  MediaAssetRepository.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation
import Combine


protocol PhotoManifestRepositoryProtocol {
    func fetchManifest(for url: URL) -> AnyPublisher<PhotoManifest, Error>
}


final class PhotoManifestRepository: PhotoManifestRepositoryProtocol {
    
    private let service: CodableGetService
    
    init(service: CodableGetService) {
        self.service = service
    }
    
    func fetchManifest(for url: URL) -> AnyPublisher<PhotoManifest, Error> {
        service
            .get(MediaAssetManifestEntity.self, url: url)
            .map { manifest in
                manifest.map { $0.url }
            }
            .map { urls in
                PhotoManifest(urls: urls)
            }
            .eraseToAnyPublisher()
    }
}
