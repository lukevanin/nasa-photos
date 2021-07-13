//
//  MockPhotosViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import Foundation
import Combine


final class MockPhotosViewModel: PhotosViewModelProtocol {
    
    typealias Fetch = () throws -> [PhotosItemViewModel]
    
    var items = CurrentValueSubject<[PhotosItemViewModel], Never>([])
    var errors = PassthroughSubject<String, Never>()
    
    var fetchDelay = TimeInterval(1)
    var mockFetch: Fetch!
    
    func reset() {
        items.value = []
    }
    
    func fetch() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + fetchDelay) { [weak self] in
            guard let self = self else {
                return
            }
            do {
                let newItems =  try self.mockFetch()
                self.items.value.append(contentsOf: newItems)
            }
            catch {
                self.errors.send(error.localizedDescription)
            }
        }
    }
}
