//
//  CodableService.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


protocol CodableGetService {
    func get<T>(_ type: T.Type, url: URL) -> AnyPublisher<T, Error> where T: Decodable
}
