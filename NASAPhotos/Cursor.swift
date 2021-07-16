//
//  Cursor.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
/// Defines a subset of data within a larger collection. Provides a reference to the next subset in the
/// collection, if available.
///
/// Use a cursor to incrementally fetch a set of data. A typical use case is fetching paginated data from a
/// web service.
///
protocol CursorProtocol {
    
    associatedtype Value
    
    ///
    /// Retrieves the subset of data that the cursor refers to.
    ///
    func fetch() -> AnyPublisher<Value, Error>

    ///
    /// Retrieves the next cursor in the collection. Returns nil if no further data is available.
    ///
    func next() -> AnyPublisher<Self?, Error>
}

extension CollectionEntity {
    
    ///
    /// Returns a link to retrieve the next subset of the collection.
    ///
    func nextLink() -> LinkEntity? {
        links.first { $0.rel == .next }
    }
}

///
/// Type erasure that a concrete interface for interacting with an abstract cursor.
///
struct AnyCursor<Value> {
    
    typealias Fetch = () -> AnyPublisher<Value, Error>
    typealias Next = () -> AnyPublisher<AnyCursor<Value>?, Error>
    
    private let internalFetch: Fetch
    private let internalNext: Next
    
    init<C>(_ cursor: C) where C: CursorProtocol, C.Value == Value {
        self.init(
            fetch: cursor.fetch,
            next: {
                cursor
                    .next()
                    .map { (cursor: C?) -> AnyCursor<Value>? in
                        cursor.flatMap { cursor in
                            AnyCursor<Value>(cursor)
                        }
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
    
    init(fetch: @escaping Fetch, next: @escaping Next) {
        self.internalFetch = fetch
        self.internalNext = next
    }
    
    func fetch() -> AnyPublisher<Value, Error> {
        internalFetch()
    }
    
    func next() -> AnyPublisher<AnyCursor<Value>?, Error> {
        internalNext()
    }
}

