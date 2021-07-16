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
protocol CursorProtocol: Equatable {
    
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

extension CursorProtocol {
    func eraseToAnyCursor() -> AnyCursor<Value> {
        AnyCursor(self)
    }
}


///
/// Concrete erasure used to interact with abstract cursor types.
///
struct AnyCursor<Value> {
    
    typealias Fetch = () -> AnyPublisher<Value, Error>
    typealias Next = () -> AnyPublisher<AnyCursor<Value>?, Error>
    typealias Equals = (AnyCursor<Value>) -> Bool
    
    private let internalFetch: Fetch
    private let internalNext: Next
    private let internalEquals: Equals
    private let internalCursor: Any
    
    func fetch() -> AnyPublisher<Value, Error> {
        internalFetch()
    }
    
    func next() -> AnyPublisher<AnyCursor<Value>?, Error> {
        internalNext()
    }
    
    static func ==(lhs: AnyCursor<Value>, rhs: AnyCursor<Value>) -> Bool {
        return lhs.internalEquals(rhs)
    }
}

extension AnyCursor {
    
    init<C>(_ cursor: C) where C: CursorProtocol, C.Value == Value {
        self.init(
            internalFetch: cursor.fetch,
            internalNext: {
                cursor
                    .next()
                    .map { (cursor: C?) -> AnyCursor<Value>? in
                        cursor.flatMap { cursor in
                            AnyCursor<Value>(cursor)
                        }
                    }
                    .eraseToAnyPublisher()
            },
            internalEquals: { other in
                (other.internalCursor as? C) == cursor
            },
            internalCursor: cursor
        )
    }

}

