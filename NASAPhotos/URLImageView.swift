//
//  URLImageView.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


final class URLImageView: UIView {
    
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
    
    var session: URLSession = .shared
    
    var queue: DispatchQueue = .global(qos: .background)

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
    
    private var imageCancellable: AnyCancellable?
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupLayout() {
        imageView.added(to: self, relativeTo: .edges)
    }
    
    private func invalidateImage() {
        dispatchPrecondition(condition: .onQueue(.main))
        imageView.image = loadedImage ?? placeholderImage
    }
    
    private func invalidateURL() {
        cancelImage()
        loadImage()
    }
    
    private func cancelImage() {
        imageCancellable?.cancel()
        imageCancellable = nil
    }
    
    private func loadImage() {
        guard let url = url else {
            return
        }
        loadedImage = nil
        imageCancellable = session
            .dataTaskPublisher(for: url)
            .receive(on: queue)
            .map { (data, _) -> UIImage? in
                UIImage(data: data, scale: 1.0)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self, url] completion in
                    guard let self = self else {
                        return
                    }
                    guard url == self.url else {
                        // The URL changed after this image started loading.
                        return
                    }
                    switch completion {
                    case .failure(_):
                        self.loadedImage = nil
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self, url] image in
                    guard let self = self else {
                        return
                    }
                    guard url == self.url else {
                        // The URL changed after this image started loading.
                        return
                    }
                    self.loadedImage = image
                }
            )
    }
}
