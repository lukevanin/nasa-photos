//
//  PhotoViewControllerBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit
import Combine


///
/// Creates a view controller that displays a photo using the NASA images API. Uses a view model that
/// loads the photo from the assets manifest.
///
final class NASAPhotoViewControllerBuilder {
    
    var errorCoordinator: ErrorCoordinatorProtocol?

    private let photoDescription: PhotoDescriptionProtocol
    private let getService: CodableGetService

    init(
        photoDescription: PhotoDescriptionProtocol,
        getService: CodableGetService
    ) {
        self.photoDescription = photoDescription
        self.getService = getService
    }
    
    func makePhotoViewController(with photo: NASAPhoto) -> PhotoViewController {
        
        // Create the repository and model that provides the photo data.
        let manifestRepository = NASAPhotoManifestRepository(
            service: getService
        )
        let model = NASAPhotoDetailsModel(
            photo: photo,
            manifestRepository: manifestRepository
        )
        
        // Create the view model that transforms the model dat into human
        // readable information.
        let viewModelBuilder = NASAPhotoInfoViewModelBuilder(
            photoDescription: photoDescription
        )
        let viewModel = PhotoViewModel(
            model: model,
            transformPhoto: viewModelBuilder.makePhotoInfoViewModel
        )
        viewModel.errorCoordinator = errorCoordinator

        // Create the view controller that displays the user interface.
        let viewController = PhotoViewController(
            viewModel: viewModel
        )
        viewController.navigationItem.title = NSLocalizedString("photo-title", comment: "Photo screen title")
        return viewController
    }
}
