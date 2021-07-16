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
struct PhotoBuilder {
    func makePhoto(for entity: CollectionItem<PhotoEntity>) -> Photo? {
        guard let item = entity.data.first else {
            return nil
        }
        let thumbnailLink = entity.links.first { $0.rel == .preview }
        let thumbnailImageURL = thumbnailLink?.href
        return Photo(
            id: item.id,
            title: item.title,
            dateCreated: item.dateCreated,
            photographer: item.photographer,
            details: item.description,
            thumbnailImageURL: thumbnailImageURL?.url,
            manifestURL: entity.href.url
        )
    }
}


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
