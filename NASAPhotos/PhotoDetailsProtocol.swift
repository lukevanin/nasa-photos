//
//  PhotoDetailsProtocol.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/19.
//

import Foundation


///
/// Defines an abstract interface for photos. Concrete photo types should be defined according to the needs
/// of each photo provider. For example, there might be separate concrete photo types for different vendors,
/// each containing data specific to each vendor.
///
protocol PhotoDetailsProtocol: PhotoProtocol {

    /// Detailed information about the photo.
    var details: String? { get }

    /// Medium resolution version of the photo.
    var previewImageURL: URL? { get }
}

extension PhotoDetailsProtocol {
    func eraseToAnyPhotoDetails() -> AnyPhotoDetails {
        AnyPhotoDetails(self)
    }
}


///
/// Type erasure for types conforming to the PhotoProtocol.
///
struct AnyPhotoDetails: PhotoDetailsProtocol {
    let id: String
    let title: String?
    let dateCreated: Date?
    let photographer: String?
    let details: String?
    let thumbnailImageURL: URL?
    let previewImageURL: URL?
}

extension AnyPhotoDetails {
    init<P>(_ photo: P) where P: PhotoDetailsProtocol {
        self.init(
            id: photo.id,
            title: photo.title,
            dateCreated: photo.dateCreated,
            photographer: photo.photographer,
            details: photo.details,
            thumbnailImageURL: photo.thumbnailImageURL,
            previewImageURL: photo.previewImageURL
        )
    }
}
