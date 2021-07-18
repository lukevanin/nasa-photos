//
//  AppCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


final class AppBuilder {

    private var cancellables = Set<AnyCancellable>()
    
    private let serviceURL: URL
    private let photoDescription: PhotoDescriptionFormatter
    private let errorCoordinator: ErrorCoordinatorProtocol
    private let photoCoordinator: PhotoCoordinator

    private let getService: CodableGetService
    private let photosModel: PagedCollectionModel<CollectionItem<PhotoEntity>, Photo>
    
    private(set) var rootViewController: UINavigationController!
    
    init() {
        #warning("TODO: Compose query URL in the model")
        let serviceURL = URL(string: "https://images-api.nasa.gov/search?q=%22%22&&media_type=image")!
        let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()
        let getService = CodableHTTPGetService(
            session: .shared,
            decoder: decoder
        )
        let repository = CollectionRepository<PhotoEntity>(
            url: serviceURL,
            service: getService
        )
        let photoBuilder = PhotoBuilder()
        let photosModel = PagedCollectionModel<CollectionItem<PhotoEntity>, Photo>(
            cursor: repository.eraseToAnyCursor(),
            transform: photoBuilder.makePhoto
        )
        let photoDescription = PhotoDescriptionFormatter(
            dateFormatter: {
                let formatter = DateFormatter()
                #warning("TODO: Use localizable string for date format")
                formatter.dateFormat = "dd MMM, YYYY"
                return formatter
            }()
        )
        let errorCoordinator = ErrorAlertCoordinator()
        let photoCoordinator = PhotoCoordinator(
            photoDescription: photoDescription,
            getService: getService
        )
        self.serviceURL = serviceURL
        self.getService = getService
        self.photoDescription = photoDescription
        self.photosModel = photosModel
        self.errorCoordinator = errorCoordinator
        self.photoCoordinator = photoCoordinator
        let viewController = makePhotosViewController()
        rootViewController = UINavigationController(
            rootViewController: viewController
        )
        rootViewController.navigationBar.prefersLargeTitles = true
        errorCoordinator.presentingViewController = rootViewController
        photoCoordinator.errorCoordinator = errorCoordinator
        photoCoordinator.navigationController = rootViewController
    }
    
    private func makePhotosViewController() -> UIViewController {
        let photoBuilder = PhotoBuilder()
        let cellBuilder = PhotoCellBuilder()
        let repository = CollectionRepository<PhotoEntity>(
            url: serviceURL,
            service: getService
        )
        let model = PagedCollectionModel(
            cursor: repository.eraseToAnyCursor(),
            transform: photoBuilder.makePhoto
        )
        let viewModel = ListViewModel(
            model: model.eraseToAnyCollection(),
            transform: makePhotoViewModel
        )
        let viewController = ListViewController(
            viewModel: viewModel,
            cellProvider: cellBuilder
        )
        viewController.navigationItem.title = NSLocalizedString("photos-title", comment: "Photos screen title")
        viewModel.errorCoordinator = errorCoordinator
        viewModel.itemCoordinator = photoCoordinator.eraseToAnyListItemCoordinator()
        return viewController
    }

    private func makePhotoViewModel(from photo: Photo) -> PhotosListItemViewModel {
        PhotosListItemViewModel(
            id: photo.id,
            thumbnailImageURL: photo.thumbnailImageURL,
            title: photo.title ?? "",
            description: photoDescription.makePhotoDescription(for: photo)
        )
    }
}
