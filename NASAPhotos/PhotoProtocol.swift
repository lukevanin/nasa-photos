//
//  Photo.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


///
/// Defines an abstract interface for photos. Concrete photo types should be defined according to the needs
/// of each photo provider. For example, there might be separate concrete photo types for different vendors,
/// each containing data specific to each vendor.
///
protocol PhotoProtocol: Identifiable, Equatable {

    /// Unique identifier of the photo.
    var id: String { get }

    /// Human readable title of the photo.
    var title: String? { get }

    /// Date when the photo was taken.
    var dateCreated: Date? { get }

    /// Name of the photographer or rights holder.
    var photographer: String? { get }

    /// Low resolution version of the photo.
    var thumbnailImageURL: URL? { get }
}

extension PhotoProtocol {
    func eraseToAnyPhoto() -> AnyPhoto {
        AnyPhoto(self)
    }
}


///
/// Type erasure for types conforming to the PhotoProtocol.
///
struct AnyPhoto: PhotoProtocol {
    let id: String
    let title: String?
    let dateCreated: Date?
    let photographer: String?
    let thumbnailImageURL: URL?
}

extension AnyPhoto {
    init<P>(_ photo: P) where P: PhotoProtocol {
        self.init(
            id: photo.id,
            title: photo.title,
            dateCreated: photo.dateCreated,
            photographer: photo.photographer,
            thumbnailImageURL: photo.thumbnailImageURL
        )
    }
}
