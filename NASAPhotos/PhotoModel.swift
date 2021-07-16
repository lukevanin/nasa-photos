//
//  PhotoModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation
import Combine


final class PhotoDetailsModel {
    
    let photo: CurrentValueSubject<Photo, Never>
    let manifest = CurrentValueSubject<PhotoManifest?, Never>(nil)
    let error = PassthroughSubject<Error, Never>()

    private var manifestCancellable: AnyCancellable?
    private let manifestRepository: PhotoManifestRepositoryProtocol
    
    init(photo: Photo, manifestRepository: PhotoManifestRepositoryProtocol) {
        self.photo = CurrentValueSubject(photo)
        self.manifestRepository = manifestRepository
    }
    
    func reload() {
        guard let manifestURL = photo.value.manifestURL else {
            error.send(URLError(.resourceUnavailable))
            return
        }
        manifestCancellable = manifestRepository
            .fetchManifest(for: manifestURL)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return
                    }
                    switch completion {
                    case .failure(let error):
                        self.error.send(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] manifest in
                    guard let self = self else {
                        return
                    }
                    self.manifest.send(manifest)
                }
            )
    }
}
