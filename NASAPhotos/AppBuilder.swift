//
//  AppCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


///
/// Constructs the components used by the application, including the initial view controller as well as any
/// dependencies used by the application.
///
final class AppBuilder {
    
    var serviceURL: URL = URL(string: "https://images-api.nasa.gov/search?q=%22%22&&media_type=image")!
    
    var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    var urlSession: URLSession = URLSession.shared

    ///
    /// Instantiates the initial view controller that is presented to the user when the app is launched.
    ///
    func makeViewController() -> UIViewController {
        
        // Create the web service.
        let getService = CodableHTTPGetService(
            session: urlSession,
            decoder: decoder
        )
        
        // Create the repository and model for fetching and aggregating photos
        // from the NASA images API.
        let nasaPhotosRepository = CollectionRepository<PhotoEntity>(
            url: serviceURL,
            service: getService
        )
        let photoBuilder = NASAPhotoBuilder()
        let nasaPhotosModel = PagedCollectionModel<CollectionItem<PhotoEntity>, NASAPhoto>(
            cursor: nasaPhotosRepository.eraseToAnyCursor(),
            transform: photoBuilder.makePhoto
        )
        
        // Create formatters for converting dates and numbers to localized text.
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            #warning("TODO: Use localizable string for date format")
            formatter.dateFormat = "dd MMM, YYYY"
            return formatter
        }()
        let photoDescription = PhotoDescriptionFormatter(
            dateFormatter: dateFormatter
        )
        
        // Create the error coordinator for displaying errors.
        let errorCoordinator = ErrorAlertCoordinator()
        
        // Create the photo coordinator for displaying details for a specific
        // photo.
        let photoViewControllerBuilder = NASAPhotoViewControllerBuilder(
            photoDescription: photoDescription,
            getService: getService
        )
        photoViewControllerBuilder.errorCoordinator = errorCoordinator
        
        let photoCoordinator = PhotoCoordinator(
            builder: photoViewControllerBuilder.makePhotoViewController
        )
        
        // Create the list of photos that are displayed
        let photosViewControllerBuilder = PhotosViewControllerBuilder(
            photoDescription: photoDescription,
            model: nasaPhotosModel.eraseToAnyCollection()
        )
        photosViewControllerBuilder.errorCoordinator = errorCoordinator
        photosViewControllerBuilder.photoCoordinator = photoCoordinator.eraseToAnyListItemCoordinator()
        
        let photosViewController = photosViewControllerBuilder.makeViewController()
        
        // Create and root navigation controller.
        let rootViewController = UINavigationController(
            rootViewController: photosViewController
        )
        rootViewController.navigationBar.prefersLargeTitles = true
        
        // Connect dependencies
        errorCoordinator.presentingViewController = rootViewController
        photoCoordinator.navigationController = rootViewController
        
        return rootViewController
    }

}
