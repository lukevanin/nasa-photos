//
//  PhotoEntity.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


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
