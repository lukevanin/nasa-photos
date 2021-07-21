//
//  PhotosViewControllerBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit


///
/// Creates a view controller that displays a list of photos using the given model.
///
final class PhotosViewControllerBuilder<Photo> where Photo: PhotoProtocol {

    var errorCoordinator: ErrorCoordinatorProtocol?
    var photoCoordinator: AnyListItemCoordinator<Photo>?
    
    private let photoDescription: PhotoDescriptionProtocol
    private let model: AnyPagedCollection<Photo>

    internal init(
        photoDescription: PhotoDescriptionProtocol,
        model: AnyPagedCollection<Photo>
    ) {
        self.photoDescription = photoDescription
        self.model = model
    }

    ///
    /// Creates and returns a view controller that displays a list of photos from the web service.
    ///
    func makeViewController() -> UIViewController {
        let viewModel = makeViewModel()
        let cellBuilder = PhotoCellBuilder()
        let viewController = ListViewController(
            viewModel: viewModel,
            cellProvider: cellBuilder
        )
        viewController.navigationItem.title = NSLocalizedString("photos-title", comment: "Photos screen title")
        return viewController
    }
    
    ///
    /// Creates a view model that provides a list of photos for displaying in the user interface.
    ///
    private func makeViewModel() -> ListViewModel<Photo, PhotosListItemViewModel> {
        let photoViewModelBuilder = PhotosListItemViewModelBuilder(
            photoDescription: photoDescription
        )
        let viewModel = ListViewModel(
            model: model,
            transform: photoViewModelBuilder.makePhotoViewModel
        )
        viewModel.errorCoordinator = errorCoordinator
        viewModel.itemCoordinator = photoCoordinator
        return viewModel
    }
}
