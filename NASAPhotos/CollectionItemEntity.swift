//
//  CollectionItemEntity.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


struct CollectionItem<Item> {
    let data: [Item]
    let links: [LinkEntity<WrappedURL>]
    let href: WrappedURL
}

extension CollectionItem: Decodable where Item: Decodable {

}
