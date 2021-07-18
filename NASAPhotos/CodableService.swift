//
//  CodableService.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
/// Abstract definition of a service that provides an interface for retreiving objects conforming to the
/// Codable protocol. Concrete implementations should fetch the raw data for the object, decode the object,
/// and return it.
///
protocol CodableGetService {
    func get<T>(_ type: T.Type, url: URL) -> AnyPublisher<T, Error> where T: Decodable
}
