//
//  PhotosRepositoryProtocol.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
///
///
final class PhotosRepository: CursorProtocol {
    
    private let photos: [CollectionItem<PhotoEntity>]
    private let nextURL: URL?
    private let service: CodableGetService
    
    ///
    /// Initializes the photos repository with a web service. In future this initializer may accept additional
    /// parameters that may be used to filter the search results.
    ///
    convenience init(url: URL, service: CodableGetService) {
        self.init(
            photos: [],
            nextURL: url,
            service: service
        )
    }
    
    ///
    /// Initializes the photos repository with a subset of data, and an optional URL that refers to the next
    /// subset in the collection. Used to initialize subsequent instances that refer to additional locations
    /// within the series.
    ///
    private init(
        photos: [CollectionItem<PhotoEntity>],
        nextURL: URL?,
        service: CodableGetService
    ) {
        self.photos = photos
        self.nextURL = nextURL
        self.service = service
    }
    
    ///
    /// Returns the set of photos which the cursor refers to.
    ///
    func fetch() -> AnyPublisher<[CollectionItem<PhotoEntity>], Error> {
        Just(photos)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    ///
    /// Fetches the next subset of photos if available.
    ///
    func next() -> AnyPublisher<PhotosRepository?, Error> {
        guard let url = nextURL else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return service
            .get(CollectionResponseEntity<PhotoEntity>.self, url: url)
            .map { [service] response in
                PhotosRepository(
                    photos: response.collection.items,
                    nextURL: response.collection.nextLink().flatMap {
                        $0.href.url
                    },
                    service: service
                )
            }
            .eraseToAnyPublisher()
    }
}

