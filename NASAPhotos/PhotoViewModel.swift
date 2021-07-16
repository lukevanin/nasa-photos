//
//  PhotoViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
/// Defines the view state for a single photo.
///
struct PhotoInfoViewModel: Identifiable {
    
    /// Unique identifier of the item.
    let id: String

    /// Text title of the photo.
    var title: String
    
    /// Short description of the photo. Includes the photographer and date that the photo was created.
    var description: String
    
    /// Detailed information about the photo.
    var details: String
}


struct PhotoViewModel {
    
    typealias TransformPhoto = (Photo) -> PhotoInfoViewModel
    
    let photo: AnyPublisher<PhotoInfoViewModel, Never>
    let previewImageURL: AnyPublisher<URL, Never>
    let error: AnyPublisher<String, Never>

    private let model: PhotoDetailsModel
    
    init(
        model: PhotoDetailsModel,
        preferredPreviewImageVariants: [PhotoManifest.Variant] = [
            .small,
            .medium,
            .original,
            .thumbnail,
        ],
        transformPhoto: @escaping TransformPhoto
    ) {
        self.model = model
        self.photo = model.photo
            .map(transformPhoto)
            .eraseToAnyPublisher()
        self.previewImageURL = model.manifest
            .compactMap { manifest in
                manifest?.firstURL(matching: preferredPreviewImageVariants)
            }
            .eraseToAnyPublisher()
        self.error = model.error
            .map { $0.localizedDescription }
            .eraseToAnyPublisher()
    }
    
    func reload() {
        model.reload()
    }
}
