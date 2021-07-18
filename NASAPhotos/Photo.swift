//
//  Photo.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation

///
///
///
struct Photo: Identifiable {
    var id: String
    var title: String?
    var dateCreated: Date?
    var photographer: String?
    var details: String?
    var thumbnailImageURL: URL?
    var manifestURL: URL?
}

extension Photo: Equatable {
    
}
