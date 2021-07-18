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


private let defaultImageQueue: DispatchQueue = {
    DispatchQueue(
        label: "images",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .inherit,
        target: nil // .global(qos: .userInitiated)
    )
}()


private let defaultImageSession: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.httpMaximumConnectionsPerHost = 4
    let session = URLSession(configuration: configuration)
    return session
}()


final class URLImageView: UIView {
    
    #warning("TODO: Refactor image loading state into view model class, and test view model")
    
    var url: URL? {
        didSet {
            invalidateURL()
        }
    }
    
    var placeholderImage: UIImage? {
        didSet {
            invalidateImage()
        }
    }
    
    var session: URLSession = defaultImageSession
    
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
    
    private func setState(_ state: AnyState) {
        currentState = state
        currentState?.context = self
        currentState?.enter()
    }
    
    // MARK: State classes
    
    
    final private class NullState: AnyState {
        
        override func enter() {
            context.loadedImage = nil
        }
        
        override func loadImage(url: URL?) {
            guard let url = url else {
                return
            }
            context.setState(LoadingState(url: url))
        }
    }
    
    
    final private class LoadingState: AnyURLState {
        
        private var cancellable: AnyCancellable?
        
        override func enter() {
            wait(delayFactor: 1)
        }
        
        private func wait(delayFactor: TimeInterval) {
            // Wait for some amount of time then perform the request.
            
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
                            // self.context.setState(NullState())
                        break
                        case .finished:
                            #warning("TODO: Log when the request completes before the image is loaded")
                            break
                        }
                        let newDelayFactor = delayFactor * delayGrowthFactor
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
    
    
    private class AnyURLState: AnyState {
        
        fileprivate let url: URL
        
        init(url: URL) {
            self.url = url
        }
        
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

    private class AnyState {
        weak var context: URLImageView!
        
        func enter() {
        }
        
        func loadImage(url: URL?) {
            
        }
    }
}
