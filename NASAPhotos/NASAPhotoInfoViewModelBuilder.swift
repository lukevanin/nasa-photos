//
//  PhotoInfoViewModelBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import Foundation


///
/// Creates a PhotoInfoViewModel from a Photo. uses a PhotoDescription formatter to compose the human
/// readable description for the photo.
///
final class NASAPhotoInfoViewModelBuilder {
    
    private let photoDescription: PhotoDescriptionProtocol
    
    init(photoDescription: PhotoDescriptionProtocol) {
        self.photoDescription = photoDescription
    }
    
    func makePhotoInfoViewModel(photo: NASAPhoto) -> PhotoInfoViewModel {
        PhotoInfoViewModel(
            id: photo.id,
            title: photo.title ?? "",
            description: photoDescription.makePhotoDescription(for: photo),
            details: photo.details ?? "",
            previewImageURL: photo.previewImageURL
        )
    }
}
