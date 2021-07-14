//
//  TestAppCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit


struct Photo {
    var id: String
    var title: String
    var description: String
    var details: String
    
    var thumbnailImageURL: URL {
        URL(string: "https://picsum.photos/id/\(id)/64")!
    }
    
    var previewImageURL: URL {
        URL(string: "https://picsum.photos/id/\(id)/375/230")!
    }
    
    var originalImageURL: URL {
        URL(string: "https://picsum.photos/id/\(id)/800/600")!
    }
}


extension PhotosItemViewModel {
    init(_ photo: Photo) {
        self.init(
            id: photo.id,
            thumbnailImageURL: photo.thumbnailImageURL,
            title: photo.title,
            description: photo.description
        )
    }
}


extension PhotoInfoViewModel {
    init(_ photo: Photo) {
        self.init(
            id: photo.id,
            previewImageURL: photo.previewImageURL,
            originalImageURL: photo.originalImageURL,
            title: photo.title,
            description: photo.description,
            details: photo.details
        )
    }
}


final class TestAppCoordinator {
    
    var photos = [
        Photo(
            id: "0",
            title: "ADC-2002-ACD02-0056-22",
            description: "Tom Trower | 20 March, 2002",
            details: "VSHAIP test in 7x10ft#1 W.T. (multiple model configurations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long."
        ),
        Photo(
            id: "1",
            title: "Expedition 22 Prelaunch Press Conference",
            description: "NASA/Bill Ingalls | 19 December, 1984",
            details: "VSHAIP test in 7x10ft#1 W.T. (multiple model configurations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long."
        ),
        Photo(
            id: "2",
            title: "Expedition 22",
            description: "NASA/Bill Ingalls | 3 July, 1953",
            details: "VSHAIP test in 7x10ft#1 W.T. (multiple model configurations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long."
        ),
    ]
    
    private(set) var rootViewController: UINavigationController!
    
    init() {
        let viewController = makePhotoViewController(
            with: PhotoInfoViewModel(photos[0])
        )
        rootViewController = UINavigationController(
            rootViewController: viewController
        )
        rootViewController.navigationBar.prefersLargeTitles = true
    }
    
    private func makePhotosViewController() -> UIViewController {
        let photosViewModel = makeViewModel()
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
        guard let photo = photos.first(where: { $0.id == photo.id }) else {
            return
        }
        let info = PhotoInfoViewModel(photo)
        showPhoto(info)
    }
    
    private func showPhoto(_ photo: PhotoInfoViewModel) {
        let viewController = makePhotoViewController(with: photo)
        rootViewController.pushViewController(viewController, animated: true)
    }
    
    private func makePhotoViewController(
        with photo: PhotoInfoViewModel
    ) -> PhotoViewController {
        let viewController = PhotoViewController(viewModel: photo)
        return viewController
    }
    
    private func makeViewModel() -> PhotosViewModelProtocol {
        let photosViewModel = MockPhotosViewModel()
        photosViewModel.mockFetch = { [photos] in
            photos.map(PhotosItemViewModel.init)
        }
//        photosViewModel.mockFetch = {
//            throw URLError(.badServerResponse)
//        }
        return photosViewModel
    }
}
