//
//  CodableURLSession.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/15.
//

import Foundation
import Combine


final class CodableHTTPGetService<Decoder>: CodableGetService where Decoder: TopLevelDecoder, Decoder.Input == Data {
    
    private let decoder: Decoder
    private let session: URLSession
    
    init(session: URLSession, decoder: Decoder) {
        self.session = session
        self.decoder = decoder
    }
    
    func get<T>(_ type: T.Type, url: URL) -> AnyPublisher<T, Error> where T : Decodable {
        session
            .dataTaskPublisher(for: url)
            .map { data, _ in
                data
            }
            .decode(type: T.self, decoder: decoder)
//            .breakpointOnError()
            .eraseToAnyPublisher()
    }
}
