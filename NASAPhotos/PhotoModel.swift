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
    private let service: CodableGetService
    
    init(photo: Photo, service: CodableGetService) {
        self.photo = CurrentValueSubject(photo)
        self.service = service
    }
    
    func reload() {
        guard let manifestURL = photo.value.manifestURL else {
            error.send(URLError(.resourceUnavailable))
            return
        }
        manifestCancellable = service
            .get(MediaAssetManifestEntity.self, url: manifestURL)
            .map { manifest in
                manifest.map { $0.url }
            }
            .map { urls in
                PhotoManifest(urls: urls)
            }
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
