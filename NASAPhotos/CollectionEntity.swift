//
//  CollectionEntity.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


struct CollectionEntity<Item> {
    
    let items: [CollectionItem<Item>]
    let links: [LinkEntity<URL>]
}

extension CollectionEntity: Decodable where Item: Decodable {
    
}

extension CollectionEntity {
    
    ///
    /// Returns a link to retrieve the next subset of the collection.
    ///
    func nextLink() -> LinkEntity<URL>? {
        links.first { $0.rel == .next }
    }
}
