//
//  ErrorMessageCoordinator.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit


protocol ErrorCoordinatorProtocol {
    typealias Retry = () -> Void
    typealias Cancel = () -> Void
    func showError(message: String, retry: Retry?, cancel: Cancel?)
}


final class ErrorAlertCoordinator: ErrorCoordinatorProtocol {
    
    weak var presentingViewController: UIViewController?
    
    func showError(message: String, retry: Retry?, cancel: Cancel?) {
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
        if let cancel = cancel {
            viewController.addAction(
                UIAlertAction(
                    title: NSLocalizedString("error-alert-cancel-button", comment: "Error alert retry button caption"),
                    style: .default,
                    handler: { _ in
                        cancel()
                    }
                )
            )
        }
        presentingViewController?.present(viewController, animated: true, completion: nil)
    }
}
