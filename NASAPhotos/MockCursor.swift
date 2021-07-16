//
//  MockCursor.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation
import Combine


///
///
///
struct MockCursor<Entity>: CursorProtocol {
    
    typealias MockFetch = () throws -> Entity
    typealias MockNext = () throws -> MockCursor<Entity>?
    
    var id: String
    var mockFetch: MockFetch!
    var mockNext: MockNext!
    
    init(
        id: String = UUID().uuidString,
        fetch: MockFetch? = nil,
        next: MockNext? = { nil }
    ) {
        self.id = id
        self.mockFetch = fetch
        self.mockNext = next
    }
    
    func fetch() -> AnyPublisher<Entity, Error> {
        Future { [mockFetch] completion in
            do {
                let result = try mockFetch!()
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func next() -> AnyPublisher<MockCursor<Entity>?, Error> {
        Future { [mockNext] completion in
            do {
                let result = try mockNext!()
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    static func ==(lhs: MockCursor<Entity>, rhs: MockCursor<Entity>) -> Bool {
        lhs.id == rhs.id
    }
}
