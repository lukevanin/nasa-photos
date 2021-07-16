//
//  CollectionRepository.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
/// General purpose repository that returns items from a collection in batches. Used to retrieve the contents
/// of a collection in stages without needing to fetch the entire collection at once.
///
/// The repository is implemented internally as a cursor, meaning that it contains a reference to the start
/// position of a batch of data, and provides methods to retrieve the batch of data, or retrieve a reference to
/// the next batch in the sequence.
///
final class CollectionRepository<Element>: CursorProtocol where Element: Equatable & Decodable {
    
    private let elements: [CollectionItem<Element>]
    private let nextURL: URL?
    private let service: CodableGetService
    
    ///
    /// Initializes the photos repository with a web service. In future this initializer may accept additional
    /// parameters that may be used to filter the search results.
    ///
    convenience init(url: URL, service: CodableGetService) {
        self.init(
            elements: [],
            nextURL: url,
            service: service
        )
    }
    
    ///
    /// Initializes the photos repository with a subset of data, and an optional URL that refers to the next
    /// subset in the collection. Used to initialize subsequent instances that refer to additional locations
    /// within the series.
    ///
    init(
        elements: [CollectionItem<Element>],
        nextURL: URL?,
        service: CodableGetService
    ) {
        self.elements = elements
        self.nextURL = nextURL
        self.service = service
    }
    
    ///
    /// Returns the batch of items that the repository refers to.
    ///
    func fetch() -> AnyPublisher<[CollectionItem<Element>], Error> {
        Just(elements)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    ///
    /// Fetches the next batch of items if available. Returns a repository that refers to the next batch of
    /// items in the sequence, or nil if no further items are available.
    ///
    func next() -> AnyPublisher<CollectionRepository?, Error> {
        guard let url = nextURL else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return service
            .get(CollectionResponseEntity<Element>.self, url: url)
            .map { [service] response in
                CollectionRepository(
                    elements: response.collection.items,
                    nextURL: response.collection.nextLink().flatMap {
                        $0.href
                    },
                    service: service
                )
            }
            .eraseToAnyPublisher()
    }
    
    static func ==(lhs: CollectionRepository, rhs: CollectionRepository) -> Bool {
        return true &&
            lhs.elements == rhs.elements &&
            lhs.nextURL == rhs.nextURL
    }
}

