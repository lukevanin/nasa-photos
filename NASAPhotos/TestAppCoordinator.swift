//
//  TestAppCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


final class TestAppCoordinator {
    
//    var photos = [
//        Photo(
//            id: "0",
//            title: "ADC-2002-ACD02-0056-22",
//            dateCreated: Date(timeIntervalSince1970: -14196536),
//            photographer: "Tom Trower",
//            details: "VSHAIP test in 7x10ft#1 W.T. (multiple model configurations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long.",
//            images: [
//                .thumbnail: URL(string: "https://picsum.photos/id/0/64")!,
//                .medium: URL(string: "https://picsum.photos/id/0/375/230")!,
//                .original: URL(string: "https://picsum.photos/id/0/800/600")!,
//            ]
//        ),
//        Photo(
//            id: "1",
//            title: "Expedition 22 Prelaunch Press Conference",
//            dateCreated: Date(timeIntervalSince1970: -14196536),
//            photographer: "NASA/Bill Ingalls",
//            details: "VSHAIP test in 7x10ft#1 W.T. (multiple model configurations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long.",
//            images: [
//                .thumbnail: URL(string: "https://picsum.photos/id/1/64")!,
//                .medium: URL(string: "https://picsum.photos/id/1/375/230")!,
//                .original: URL(string: "https://picsum.photos/id/1/800/600")!,
//            ]
//        ),
//        Photo(
//            id: "2",
//            title: "Expedition 22",
//            dateCreated: Date(timeIntervalSince1970: -14196536),
//            photographer: "NASA/Bill Ingalls",
//            details: "VSHAIP test in 7x10ft#1 W.T. (multiple model configurations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long.",
//            images: [
//                .thumbnail: URL(string: "https://picsum.photos/id/2/64")!,
//                .medium: URL(string: "https://picsum.photos/id/2/375/230")!,
//                .original: URL(string: "https://picsum.photos/id/2/800/600")!,
//            ]
//        ),
//    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    private let photoDescription: PhotoDescriptionBuilder
    
    private let getService: CodableGetService
    private let photosModel: PhotosModel
    
    private(set) var rootViewController: UINavigationController!
    
    init() {
//        let viewController = makePhotoViewController(
//            with: makePhotoInfoViewModel(photos[0])
//        )
        let baseURL = URL(string: "https://images-api.nasa.gov/search?q=%22%22")!
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
        let repository = PhotosRepository(
            url: baseURL,
            service: getService
        )
        let photoBuilder = PhotoBuilder(
            service: getService
        )
        let photosModel = PhotosModel(
            cursor: AnyCursor(repository),
            transform: photoBuilder.makePhoto
        )
        let photoDescription = PhotoDescriptionBuilder(
            dateFormatter: {
                let formatter = DateFormatter()
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
        guard let photo = photosModel.photos.value.first(where: { $0.id == photo.id }) else {
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
        let model = PhotoDetailsModel(
            photo: photo,
            service: getService
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
