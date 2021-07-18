//
//  URLImageView.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


private let delayGrowthFactor = TimeInterval(3)
private let delayInterval = TimeInterval(0.2)


///
/// Default queue used by URLImageView for image processing.
///
private let defaultImageQueue: DispatchQueue = {
    DispatchQueue(
        label: "images",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .inherit,
        target: nil // .global(qos: .userInitiated)
    )
}()


///
/// Default URLSession used by URLImageView for downloading images.
///
private let defaultImageSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.httpMaximumConnectionsPerHost = 4
    let session = URLSession(configuration: configuration)
    return session
}()


///
/// Downloads and displays an image from the network. Retries downloading the image, with successively
/// longer delays, if the image cannot be downloaded.
///
/// Implemented internally using a simple Finite State Machine (FSM), where the states are:
/// - Null: URL is set to nil
/// - Loading: URL is defined, and the image is currently being downloaded.
/// - Loaded: The image is downloaded and being displayed.
/// 
/// See the individual state classes at the end of this file for details about each state.
///
final class URLImageView: UIView {
    
    #warning("TODO: Refactor image loading state into view model class, and test view model")
    
    ///
    /// URL of the image to download and display. Any download that is already in progress will be stopped
    /// when the url is set. The download is reattempted with successfully longer delays if the
    /// download fails.
    ///
    var url: URL? {
        didSet {
            invalidateURL()
        }
    }
    
    ///
    /// Placeholder image to display while the image is downloading, and when the image URL is nil.
    ///
    var placeholderImage: UIImage? {
        didSet {
            invalidateImage()
        }
    }
    
    ///
    /// URLSession used to download the data for the image.
    ///
    var session: URLSession = defaultImageSession
    
    ///
    /// Queue used to execute background processing, such as parseing image data. This should be set
    /// to a background queue to avoid interrupting the main thread.
    ///
    var queue: DispatchQueue = defaultImageQueue

    override var contentMode: ContentMode {
        get {
            imageView.contentMode
        }
        set {
            imageView.contentMode = newValue
        }
    }

    private var loadedImage: UIImage? {
        didSet {
            invalidateImage()
        }
    }
    
    private let imageView = UIImageView()
    
    private var currentState: AnyState?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setState(NullState())
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupLayout() {
        backgroundColor = .systemGray5
        imageView.added(to: self, relativeTo: .edges)
    }
    
    private func invalidateImage() {
        dispatchPrecondition(condition: .onQueue(.main))
        #warning("TODO: Show loading indicator when the image is nil and the url is not nil")
        let newImage = loadedImage ?? placeholderImage
        if newImage != nil {
            UIView.transition(
                with: imageView,
                duration: 0.2,
                options: [.transitionCrossDissolve],
                animations: {
                    self.imageView.image = newImage
                },
                completion: nil
            )
        }
        else {
            UIView.performWithoutAnimation {
                imageView.image = newImage
            }
        }
    }
    
    private func invalidateURL() {
        currentState?.loadImage(url: url)
    }
    
    // MARK: State management
    
    ///
    /// Replaces the current image state with a new state. The old state is deallocated and the new state is
    /// entered immediately when this method is called.
    ///
    private func setState(_ state: AnyState) {
        currentState = state
        currentState?.context = self
        currentState?.enter()
    }
    
    // MARK: State classes
    
    ///
    /// Image state when no URL is defined. Removes the loaded image and displays the placeholder
    /// image if available.
    ///
    /// Transitions to the Loading state when a load request is initiated (ie when the URL is set to a
    /// non-null value).
    ///
    final private class NullState: AnyState {
        
        ///
        /// Removes the loaded image, causing the placeholder image to be displayed, if available.
        ///
        override func enter() {
            context.loadedImage = nil
        }
        
        ///
        /// Transitions to the loading state and starts the image if a URL is provided, otherwise
        /// does nothing.
        ///
        override func loadImage(url: URL?) {
            guard let url = url else {
                return
            }
            context.setState(LoadingState(url: url))
        }
    }
    
    
    ///
    /// Image state while an image is being downloaded. If the image download fails, attempts to retry
    /// downloading the image with successively longer intervals between attempts.
    ///
    /// Transitions to the loaded state when the image is loaded.
    ///
    final private class LoadingState: AnyURLState {
        
        private var cancellable: AnyCancellable?
        
        ///
        /// Starts loading the image with a minimal delay. The initial delay is to avoid unnecessarily
        /// calling the web service when the URL is changing rapidly (such as when the URLImageView
        /// is used in a table or collection view cell, that is scrolling quickly).
        ///
        override func enter() {
            wait(delayFactor: 1)
        }
        
        private func wait(delayFactor: TimeInterval) {
            let delay = delayInterval * delayFactor
            DispatchQueue
                .global(qos: .default)
                .asyncAfter(wallDeadline: .now() + delay) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.performRequest(delayFactor: delayFactor)
                }
        }
        
        private func performRequest(delayFactor: TimeInterval) {
            let request = URLRequest(
                url: url.usingHTTPS(),
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10
            )
            cancellable = context.session
                .dataTaskPublisher(for: request)
                .receive(on: context.queue)
                .tryMap { (data, _) -> UIImage in
                    guard let image = UIImage(data: data, scale: 1.0) else {
                        throw URLError(.badServerResponse)
                    }
                    return image
                }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else {
                            return
                        }
                        switch completion {
                        case .failure(_):
                            #warning("TODO: Log the error here")
                            break
                        case .finished:
                            #warning("TODO: Log when the request completes before the image is loaded")
                            break
                        }
                        let newDelayFactor = delayFactor * delayGrowthFactor
                        #warning("TODO: Use os.log")
                        print("Retrying request after \(newDelayFactor) seconds")
                        self.wait(delayFactor: newDelayFactor)
                    },
                    receiveValue: { [weak self] image in
                        guard let self = self else {
                            return
                        }
                        self.context.setState(
                            LoadedState(image: image, url: self.url)
                        )
                    }
                )
        }
    }
    
    ///
    /// State when the image is loaded. Displays the loaded image.
    ///
    final private class LoadedState: AnyURLState {
        
        private let image: UIImage
        
        init(image: UIImage, url: URL) {
            self.image = image
            super.init(url: url)
        }
        
        override func enter() {
            context.loadedImage = image
        }
    }
    
    
    ///
    /// Abstract base class used for all image states where a URL is defined, namely: Loading and Loaded
    /// image states.
    ///
    private class AnyURLState: AnyState {
        
        fileprivate let url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        ///
        /// Loads the image if the  provided URL is different to the current URL.
        ///
        override final func loadImage(url: URL?) {
            if let url = url {
                if url != self.url {
                    context.setState(LoadingState(url: url))
                }
            }
            else {
                context.setState(NullState())
            }
        }
    }

    
    ///
    /// Abstract base class used by all image states.
    ///
    private class AnyState {
        weak var context: URLImageView!
        
        func enter() {
        }
        
        func loadImage(url: URL?) {
            
        }
    }
}
