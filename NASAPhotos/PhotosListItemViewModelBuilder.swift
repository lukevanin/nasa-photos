//
//  PhotosListItemViewModelBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import Foundation


///
/// Creates a PhotosListItemViewModel for a photo in a list. Uses a PhotoDescription to create the description
/// of the photo.
///
final class PhotosListItemViewModelBuilder {
    
    private let photoDescription: PhotoDescriptionProtocol
    
    init(photoDescription: PhotoDescriptionProtocol) {
        self.photoDescription = photoDescription
    }
    
    func makePhotoViewModel<P>(at index: Int, with photo: P) -> PhotosListItemViewModel where P: PhotoProtocol {
        PhotosListItemViewModel(
            id: String(index),
            thumbnailImageURL: photo.thumbnailImageURL,
            title: photo.title ?? "",
            description: photoDescription.makePhotoDescription(for: photo)
        )
    }
}
