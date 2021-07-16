//
//  CodableURLSession.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/15.
//

import Foundation
import Combine


///
/// Provides an interface for fetching objects that conform to the Decodable protocol, from an HTTP endpoint.
/// Fetches data using a `URLSession` data task. Decodes the resulting data to the given object type.
///
final class CodableHTTPGetService<Decoder>: CodableGetService where Decoder: TopLevelDecoder, Decoder.Input == Data {
    
    private let decoder: Decoder
    private let session: URLSession
    
    ///
    /// Initializes the service using the given URL session and Decoder. The URL session is used to retrieve
    /// raw data. The decoder is used to transform the data into the expected object type.
    ///
    init(session: URLSession, decoder: Decoder) {
        self.session = session
        self.decoder = decoder
    }
    
    ///
    /// Fetches, decodes, and returns an object of the given type, from the given URL. Returns an error
    /// if the data cannot be retrieved, or if the data cannot be transformed into the expected object type.
    ///
    func get<T>(_ type: T.Type, url: URL) -> AnyPublisher<T, Error> where T : Decodable {
        session
            .dataTaskPublisher(for: url.usingHTTPS())
            .map { data, _ in
                data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
