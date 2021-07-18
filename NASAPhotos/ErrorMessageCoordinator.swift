//
//  ErrorMessageCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit


///
/// Defines an abstract inteface for presenting error messages.
///
protocol ErrorCoordinatorProtocol: AnyObject {
    typealias Retry = () -> Void
    typealias Cancel = () -> Void
    func showError(message: String, cancellable: Bool, retry: Retry?)
}


///
/// Presents an alert with information about an error. Optionally displays a cancel and retry button.
///
final class ErrorAlertCoordinator: ErrorCoordinatorProtocol {
    
    weak var presentingViewController: UIViewController?
    
    ///
    /// Presents an alert with the provided error message. Optionally displays a cancel and/or retry button.
    /// Calls the provided closure when the retry button is tapped.
    ///
    func showError(message: String, cancellable: Bool, retry: Retry?) {
        let viewController = UIAlertController(
            title: NSLocalizedString("error-alert-title", comment: "Error alert title"),
            message: message,
            preferredStyle: .alert
        )
        if let retry = retry {
            viewController.addAction(
                UIAlertAction(
                    title: NSLocalizedString("error-alert-retry-button", comment: "Error alert retry button caption"),
                    style: .default,
                    handler: { _ in
                        retry()
                    }
                )
            )
        }
        if cancellable {
            viewController.addAction(
                UIAlertAction(
                    title: NSLocalizedString("error-alert-cancel-button", comment: "Error alert retry button caption"),
                    style: .default,
                    handler: nil
                )
            )
        }
        presentingViewController?.present(viewController, animated: true, completion: nil)
    }
}
