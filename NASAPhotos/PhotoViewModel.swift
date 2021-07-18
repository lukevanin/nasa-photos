//
//  PhotoViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
///
///
final class PhotoViewModel: PhotoViewModelProtocol {
    
    typealias TransformPhoto = (Photo) -> PhotoInfoViewModel
    
    let photo: AnyPublisher<PhotoInfoViewModel, Never>
    let previewImageURL: AnyPublisher<URL, Never>
    
    var errorCoordinator: ErrorCoordinatorProtocol?

    private var cancellables = Set<AnyCancellable>()
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
