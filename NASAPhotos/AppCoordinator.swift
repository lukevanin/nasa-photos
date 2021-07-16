//
//  AppCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


final class AppCoordinator {

    private var cancellables = Set<AnyCancellable>()
    
    private let photoDescription: PhotoDescriptionBuilder
    
    private let getService: CodableGetService
    private let photosModel: PagedCollectionModel<CollectionItem<PhotoEntity>, Photo>
    
    private(set) var rootViewController: UINavigationController!
    
    init() {
        #warning("TODO: Compose query URL in the model")
        let baseURL = URL(string: "https://images-api.nasa.gov/search?q=%22%22&&media_type=image")!
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
            url: baseURL,
            service: getService
        )
        let photoBuilder = PhotoBuilder()
        let photosModel = PagedCollectionModel<CollectionItem<PhotoEntity>, Photo>(
            cursor: repository.eraseToAnyCursor(),
            transform: photoBuilder.makePhoto
        )
        let photoDescription = PhotoDescriptionBuilder(
            dateFormatter: {
                let formatter = DateFormatter()
                #warning("TODO: Use localizable string for date format")
                formatter.dateFormat = "dd MMM, YYYY"
                return formatter
            }()
        )
        self.getService = getService
        self.photoDescription = photoDescription
        self.photosModel = photosModel
        let viewController = makePhotosViewController()
        rootViewController = UINavigationController(
            rootViewController: viewController
        )
        rootViewController.navigationBar.prefersLargeTitles = true
    }
    
    private func makePhotosViewController() -> UIViewController {
        let photosViewModel = makePhotosViewModel()
        let viewController = PhotosViewController(
            viewModel: photosViewModel,
            onSelectItem: { photo in
                // Hold a strong reference to this coordinator instance to
                // keep it from be deallocated.
                self.showPhoto(photo)
            }
        )
        return viewController
    }
    
    private func showPhoto(_ photo: PhotosItemViewModel) {
        guard let photo = photosModel.elements.value.first(where: { $0.id == photo.id }) else {
            return
        }
        showPhoto(photo)
    }
    
    private func showPhoto(_ photo: Photo) {
        let viewController = makePhotoViewController(with: photo)
        rootViewController.pushViewController(viewController, animated: true)
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
        return viewController
    }
    
    private func makePhotosViewModel() -> PhotosViewModelProtocol {
        return PhotosViewModel(
            model: photosModel,
            transform: makePhotosItemViewModel
        )
    }
    
    func makePhotosItemViewModel(with photo: Photo) -> PhotosItemViewModel {
        PhotosItemViewModel(
            id: photo.id,
            thumbnailImageURL: photo.thumbnailImageURL,
            title: photo.title ?? "",
            description: photoDescription.makePhotoDescription(for: photo)
        )
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
