//
//  NASAPhotoBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import Foundation


///
/// Creates a Photo from a PhotoEntity from the NASA images API.
///
final class NASAPhotoBuilder {
    
    func makePhoto(index: Int, entity: CollectionItem<PhotoEntity>) -> Photo? {
        guard let item = entity.data.first else {
            return nil
        }
        let thumbnailLink = entity.links?.first { $0.rel == .preview }
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
