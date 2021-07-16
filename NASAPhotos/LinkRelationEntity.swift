//
//  LinkRelationEntity.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation

enum LinkRelation: String {
    case preview
    case next
    case prev
    case captions
}

extension LinkRelation: Decodable {
    
}
