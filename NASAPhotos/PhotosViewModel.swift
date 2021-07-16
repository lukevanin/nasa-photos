//
//  PhotosViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import Foundation
import Combine


///
/// Defines the view state for a single photo.
///
struct PhotosItemViewModel: Identifiable {
    
    /// Unique identifier of the item
    let id: String
    
    /// Url of the thumbnail image to display
    var thumbnailImageURL: URL?
    
    /// Text title of the photo
    var title: String
    
    /// Short description of the photo. Includes the photographer and date that the photo was created.
    var description: String
}

extension PhotosItemViewModel: Hashable {
    
}


protocol PhotosViewModelProtocol {
    
    ///
    /// Publishes available items.
    ///
    var items: CurrentValueSubject<[PhotosItemViewModel], Never> { get }
    
    ///
    /// Publishes an error if a fetch request fails.
    ///
    var errors: PassthroughSubject<String, Never> { get }

    ///
    /// Fetches the next page of items. If no more items are available then this does nothing.
    ///
    func reset()
    
    ///
    /// Resets the internal state of the view model so that the next fetch will retrieve the first page of items.
    ///
    func fetch()
}


final class PhotosViewModel: PhotosViewModelProtocol {
    
    typealias Model = PagedCollectionModel<PhotoEntity, Photo>
    typealias Transform = (Photo) -> PhotosItemViewModel
    
    var items = CurrentValueSubject<[PhotosItemViewModel], Never>([])
    var errors = PassthroughSubject<String, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let model: Model
    
    init(model: Model, transform: @escaping Transform) {
        self.model = model
        model.elements
            .map { photos in
                photos.map(transform)
            }
            .sink { [weak self] items in
                self?.items.send(items)
            }
            .store(in: &cancellables)
        model.errors
            .sink { [weak self] error in
                self?.errors.send(error.localizedDescription)
            }
            .store(in: &cancellables)
    }
    
    func reset() {
        model.reset()
    }
    
    func fetch() {
        model.fetch()
    }
}
