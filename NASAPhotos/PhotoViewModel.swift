//
//  PhotoViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
/// Models the view state for a single photo. Transforms photo model to a photo info view model that can be
/// displayed in a user interface.
///
final class PhotoViewModel<Model>: PhotoViewModelProtocol where Model: PhotoDetailsModelProtocol {
    
    #warning("TODO: Erase model type and use AnyPhotoDetailsModel instead")
    
    typealias TransformPhoto = (_ photo: Model.Photo) -> PhotoInfoViewModel
    
    let photo: AnyPublisher<PhotoInfoViewModel, Never>
    
    var errorCoordinator: ErrorCoordinatorProtocol?

    private var cancellables = Set<AnyCancellable>()
    private let model: Model
    
    init(
        model: Model,
        transformPhoto: @escaping TransformPhoto
    ) {
        self.photo = model.photo
            .map(transformPhoto)
            .eraseToAnyPublisher()
        self.model = model
        model.error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else {
                    return
                }
                self.showError(message: error.localizedDescription)
            }
            .store(in: &cancellables)
    }
    
    func reload() {
        model.reload()
    }
    
    private func showError(message: String) {
        errorCoordinator?.showError(
            message: message,
            cancellable: true,
            retry: { [weak self] in
                guard let self = self else {
                    return
                }
                self.model.reload()
            }
        )
    }
}
