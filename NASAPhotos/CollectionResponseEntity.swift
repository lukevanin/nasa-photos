//
//  CollectionResponseDTO.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation


struct CollectionResponseEntity<Item> {
    let collection: CollectionEntity<Item>
}

extension CollectionResponseEntity: Decodable where Item: Decodable {
    
}
