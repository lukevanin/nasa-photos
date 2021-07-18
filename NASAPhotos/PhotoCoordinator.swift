//
//  PhotoCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit

final class PhotoCoordinator: ListItemCoordinator {
    
    weak var navigationController: UINavigationController?
    weak var errorCoordinator: ErrorCoordinatorProtocol?

    private let photoDescription: PhotoDescriptionProtocol
    private let getService: CodableGetService

    init(
        photoDescription: PhotoDescriptionProtocol,
        getService: CodableGetService
    ) {
        self.photoDescription = photoDescription
        self.getService = getService
    }
    
    func showItem(item: Photo) {
        let viewController = makePhotoViewController(with: item)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func makePhotoViewController(
        with photo: Photo
    ) -> PhotoViewController {
        let manifestRepository = PhotoManifestRepository(
            service: getService
        )
        let model = PhotoDetailsModel(
            photo: photo,
            manifestRepository: manifestRepository
        )
        let viewModel = PhotoViewModel(
            model: model,
            transformPhoto: makePhotoInfoViewModel
        )
        let viewController = PhotoViewController(
            viewModel: viewModel
        )
        viewModel.errorCoordinator = errorCoordinator
        return viewController
    }
    
    func makePhotoInfoViewModel(with photo: Photo) -> PhotoInfoViewModel {
        PhotoInfoViewModel(
            id: photo.id,
            title: photo.title ?? "",
            description: photoDescription.makePhotoDescription(for: photo),
            details: photo.details ?? ""
        )
    }
}
