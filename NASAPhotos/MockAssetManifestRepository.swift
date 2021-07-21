//
//  MockNasaManifestRepository.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/20.
//

import Foundation
import Combine


final class MockAssetManifestRepository: AssetManifestRepositoryProtocol {
    
    typealias FetchManifest = (URL) throws -> [URL]
    
    var mockFetchManifest: FetchManifest!
    
    func fetchManifest(for url: URL) -> AnyPublisher<MediaAssetManifestEntity, Error> {
        Future { [mockFetchManifest] completion in
            do {
                let value = try mockFetchManifest!(url)
                let output = value.map {
                    WrappedURLEntity(url: $0)
                }
                completion(.success(output))
            }
            catch {
                completion(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
