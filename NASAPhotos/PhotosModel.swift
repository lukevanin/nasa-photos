//
//  PhotosModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine

///
///
///
struct PhotoManifest {
    enum Variant {
        case small
        case medium
        case original
        case thumbnail
    }
    
    let assets: [Variant : URL]
}

extension PhotoManifest {
    private static let variantNames: [String : Variant] = [
        "small": .small,
        "medium": .medium,
        "orig": .original,
        "thumb": .thumbnail,
    ]
    
    init(urls: [URL]) {
        var assets = [Variant : URL]()
        for url in urls {
            guard let variant = Self.variant(for: url.path) else {
                continue
            }
            assets[variant] = url
        }
        self.assets = assets
    }
    
    static func variant(for path: String) -> Variant? {
        let components = path.split(separator: "~")
        guard components.count == 2 else {
            return nil
        }
        let suffixes = components[1].split(separator: ".")
        guard suffixes.count == 2 else {
            return nil
        }
        let name = String(suffixes[0])
        let variant = variantNames[name]
        return variant
    }
}

extension PhotoManifest {
    func firstURL(matching variants: [Variant]) -> URL? {
        for variant in variants {
            if let url = assets[variant] {
                return url
            }
        }
        return nil
    }
}


///
///
///
struct Photo {
    var id: String
    var title: String?
    var dateCreated: Date?
    var photographer: String?
    var details: String?
    var thumbnailImageURL: URL?
    var manifestURL: URL?
}


///
///
///
final class PhotoBuilder {
    
    private let service: CodableGetService
    
    init(service: CodableGetService) {
        self.service = service
    }
    
    func makePhoto(for entity: CollectionItem<PhotoEntity>) -> Photo? {
        guard let item = entity.data.first else {
            return nil
        }
        let thumbnailLink = entity.links.first { $0.rel == .preview }
        let thumbnailImageURL = thumbnailLink?.href
        return Photo(
            id: item.id,
            title: item.title,
            dateCreated: item.dateCreated,
            photographer: item.photographer,
            details: item.description,
            thumbnailImageURL: thumbnailImageURL?.url,
            manifestURL: entity.href.url
        )
    }
//
//    private static let variantNames: [Photo.Variant : String] = [
//        .thumbnail: "thumb",
//        .medium: "medium",
//        .small: "small",
//        .original: "original",
//    ]
//
//    private func imageVariants(for url: URL?) -> [Photo.Variant : URL] {
//        var output = [Photo.Variant : URL]()
//        guard let url = url else {
//            // No URL was provided.
//            return output
//        }
//        let components = url.absoluteString.split(separator: "~")
//        guard components.count == 2 else {
//            // The URL does match the expected format.
//            return output
//        }
//        guard components[1] == "thumb.jpg" else {
//            // The URL does match the expected format.
//            return output
//        }
//        for (variant, name) in Self.variantNames {
//            let suffix = "~\(name).jpg"
//            if let url = URL(string: components[0] + suffix) {
//                output[variant] = url
//            }
//        }
//        return output
//    }
}


///
///
///
final class PhotosModel {
    
    typealias Cursor = AnyCursor<[CollectionItem<PhotoEntity>]>
    
    
    ///
    /// Base class used for all states implemented by the cursor model.
    ///
    fileprivate class AnyModelState {
        weak var context: PhotosModel!
        
        fileprivate let cursor: Cursor?
        
        init(cursor: Cursor?) {
            self.cursor = cursor
        }
        
        func enter() {
        }
        
        func fetch() {
        }
        
        func cancel() {
        }
    }


    ///
    /// Model is ready to serve a request.
    ///
    fileprivate class NextPendingModelState: AnyModelState {

        ///
        /// Fetches the next subset of data within the sequence.
        ///
        override func fetch() {
            context.setState(NextModelState(cursor: cursor))
        }
    }


    ///
    /// Model is fetching the cursor for the next subset of the sequence.
    ///
    fileprivate class NextModelState: AnyModelState {
        
        private var cancellable: AnyCancellable?
        
        ///
        /// Fetchs the cursor for the next subset of data.
        ///
        override func enter() {
            cancellable = cursor?
                .next()
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else {
                            return
                        }
                        switch completion {
                        case .failure(let error):
                            // An error occurred while fetching the next
                            // cursor. Publish an error and return to the
                            // pending state.
                            self.context.errors.send(error)
                            self.context.setState(NextPendingModelState(cursor: self.cursor))
                        case .finished:
                            break
                        }
                    },
                    receiveValue: { [weak self] cursor in
                        guard let self = self else {
                            return
                        }
                        self.context.setState(FetchModelState(cursor: cursor))
                    }
                )
        }
        
        override func cancel() {
            cancellable?.cancel()
            context.setState(NextPendingModelState(cursor: cursor))
        }
    }


    ///
    /// Model is fetching the data for the current cursor.
    ///
    fileprivate class FetchModelState: AnyModelState {
        
        private var cancellable: AnyCancellable?
        
        override func enter() {
            cancellable = cursor?
                .fetch()
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else {
                            return
                        }
                        switch completion {
                        case .failure(let error):
                            // An error occurred while fetching the contents
                            // for the cursor. Publish an error and go to the
                            // failure state.
                            self.context.errors.send(error)
                            self.context.setState(FetchPendingModelState(cursor: self.cursor))
                        case .finished:
                            break
                        }
                    },
                    receiveValue: { [weak self] entities in
                        guard let self = self else {
                            return
                        }
                        // Received the data for the cursor. Publish the new
                        // data then return to the pending state to wait for
                        // the next fetch call.
                        self.context.append(entities)
                        self.context.setState(NextPendingModelState(cursor: self.cursor))
                    }
                )
        }
        
        override func cancel() {
            cancellable?.cancel()
            context.setState(FetchPendingModelState(cursor: cursor))
        }
    }
    
    ///
    ///
    ///
    fileprivate class FetchPendingModelState: AnyModelState {
        
        override func fetch() {
            context.setState(FetchModelState(cursor: cursor))
        }
    }
    
    // MARK: Properties
    
    typealias Transform = (CollectionItem<PhotoEntity>) -> Photo?
    
    let photos = CurrentValueSubject<[Photo], Never>([])
    let errors = PassthroughSubject<Error, Never>()
    
    private var currentState: AnyModelState?
    
    private let initialCursor: Cursor
    private let transform: Transform
    
    // MARK: Public interface
    
    init(cursor: Cursor, transform: @escaping Transform) {
        self.initialCursor = cursor
        self.transform = transform
        reset()
    }

    ///
    /// Retrieves the next set of photos. Appends the returned photos to the output and
    /// publishes the aggregate of all of the photos received.
    ///
    func fetch() {
        currentState?.fetch()
    }
    
    ///
    /// Cancels the current fetch request.
    ///
    func cancel() {
        currentState?.cancel()
    }

    ///
    /// Resets the current cursor to the initial state. Cancels the current fetch request.
    ///
    func reset() {
        currentState?.cancel()
        setState(NextPendingModelState(cursor: initialCursor))
    }
    
    // MARK: Internal methods
    
    private func append(_ entities: [CollectionItem<PhotoEntity>]) {
        let photos = entities.compactMap(transform)
        self.photos.value.append(contentsOf: photos)
    }
    
    // MARK: State management
    
    private func setState(_ state: AnyModelState) {
        currentState = state
        currentState?.context = self
        currentState?.enter()
    }
}
