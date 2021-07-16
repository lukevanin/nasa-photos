//
//  URLEntity.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation

struct WrappedURL: Equatable, Decodable {
    let url: URL
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let unsafeString = try container.decode(String.self)
        let safeString = unsafeString.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed.union(.urlHostAllowed)
        )!
        guard let url = URL(string: safeString) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid URL string: \(unsafeString)"
            )
        }
        self.url = url
    }
}
