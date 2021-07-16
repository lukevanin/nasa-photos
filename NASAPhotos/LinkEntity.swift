//
//  LinkEntity.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


struct LinkEntity<URL> {
    let href: URL
    let rel: LinkRelation
}

extension LinkEntity: Equatable where URL: Equatable {
    
}

extension LinkEntity: Decodable where URL: Decodable {
    
}
