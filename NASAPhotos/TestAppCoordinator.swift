//
//  TestAppCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit


final class TestAppCoordinator {
    
    private(set) var rootViewController: UINavigationController!
    
    init() {
        let viewController = makePhotosViewController()
        rootViewController = UINavigationController(
            rootViewController: viewController
        )
        rootViewController.navigationBar.prefersLargeTitles = true
    }
    
    private func makePhotosViewController() -> UIViewController {
        let photosViewModel = makeViewModel()
        let viewController = PhotosViewController(
            viewModel: photosViewModel,
            onSelectItem: { viewController, photo in
                // We are intentionally keeping a strong reference to the
                // coordinator here so that the instance stays alive.
                self.showPhoto(photo)
            }
        )
        return viewController
    }
    
    private func showPhoto(
        _ photo: PhotosItemViewModel
    ) {
        let viewController = PhotoViewController()
        rootViewController.pushViewController(viewController, animated: true)
    }
    
    private func makeViewModel() -> PhotosViewModelProtocol {
        let photosViewModel = MockPhotosViewModel()
        photosViewModel.mockFetch = {
            [
                PhotosItemViewModel(
                    id: "0",
                    thumbnailImageURL: URL(string: "https://picsum.photos/id/0/64")!,
                    title: "ADC-2002-ACD02-0056-22",
                    description: "Tom Trower | 20 March, 2002"
                ),
                PhotosItemViewModel(
                    id: "1",
                    thumbnailImageURL: URL(string: "https://picsum.photos/id/1/64")!,
                    title: "Expedition 22 Prelaunch Press Conference",
                    description: "NASA/Bill Ingalls | 19 December, 1984"
                ),
                PhotosItemViewModel(
                    id: "2",
                    thumbnailImageURL: URL(string: "https://picsum.photos/id/2/64")!,
                    title: "Expedition 22",
                    description: "NASA/Bill Ingalls | 3 July, 1953"
                ),
            ]
        }
        return photosViewModel
    }
}
