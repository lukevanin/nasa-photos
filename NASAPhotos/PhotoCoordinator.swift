//
//  PhotoCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit


///
/// Presents a view controller with information about the given photo.
///
final class PhotoCoordinator<Photo>: ListItemCoordinator {
    
    #warning("TODO: Refactor into generic detail view coordinator")
    
    weak var navigationController: UINavigationController?

    typealias Builder = (_ photo: Photo) -> UIViewController?
    
    private let builder: Builder
    
    init(builder: @escaping Builder) {
        self.builder = builder
    }
    
    func showItem(item: Photo) {
        guard let navigationController = navigationController else {
            return
        }
        guard let viewController = builder(item) else {
            return
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}
