//
//  CollectionResponseDTO.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
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


typealias MediaAssetManifestEntity = [WrappedURL]


enum LinkRelation: String {
    case preview
    case next
    case prev
    case captions
}

extension LinkRelation: Decodable {
    
}


struct LinkEntity<URL> {
    let href: URL
    let rel: LinkRelation
}

extension LinkEntity: Equatable where URL: Equatable {
    
}

extension LinkEntity: Decodable where URL: Decodable {
    
}


struct PhotoEntity {
    let nasaId: String
    let dateCreated: Date
    let title: String?
    let photographer: String?
    let description: String?
}

extension PhotoEntity: Identifiable {
    var id: String {
        nasaId
    }
}

extension PhotoEntity: Equatable {
    
}

extension PhotoEntity: Decodable {
    
}


struct CollectionItem<Item> {
    let data: [Item]
    let links: [LinkEntity<WrappedURL>]
    let href: WrappedURL
}

extension CollectionItem: Decodable where Item: Decodable {

}


struct CollectionEntity<Item> {
    
    let items: [CollectionItem<Item>]
    let links: [LinkEntity<URL>]
}

extension CollectionEntity: Decodable where Item: Decodable {
    
}


struct CollectionResponseEntity<Item> {
    let collection: CollectionEntity<Item>
}

extension CollectionResponseEntity: Decodable where Item: Decodable {
    
}
