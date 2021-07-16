//
//  MockCodableGetService.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation
import Combine


struct MockCodableGetService: CodableGetService {
    
    typealias MockGet = (URL) throws -> Any
    
    private let mockGet: MockGet
    
    init(mockGet: @escaping MockGet) {
        self.mockGet = mockGet
    }
    
    func get<T>(_ type: T.Type, url: URL) -> AnyPublisher<T, Error> where T : Decodable {
        Future { completion in
            do {
                let result = try mockGet(url) as! T
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
