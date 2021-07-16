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
    
    typealias Transform = ([URL]) -> PhotoManifest
    
    private let service: CodableGetService
    private let transform: Transform
    
    init(
        service: CodableGetService,
        transform: @escaping Transform = {
            let builder = PhotoManifestBuilder()
            return builder.makePhotoManifest
        }()
    ) {
        self.service = service
        self.transform = transform
    }
    
    func fetchManifest(for url: URL) -> AnyPublisher<PhotoManifest, Error> {
        service
            .get(MediaAssetManifestEntity.self, url: url)
            .map { manifest in
                manifest.map { $0.url }
            }
            .map { [transform] urls in
                transform(urls)
            }
            .eraseToAnyPublisher()
    }
}
