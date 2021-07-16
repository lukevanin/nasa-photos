//
//  CollectionItemEntity.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


struct CollectionItem<Item> {
    let data: [Item]
    let links: [LinkEntity<WrappedURLEntity>]
    let href: WrappedURLEntity
}

extension CollectionItem: Equatable where Item: Equatable {
    
}

extension CollectionItem: Decodable where Item: Decodable {

}
