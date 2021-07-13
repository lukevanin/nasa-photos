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
    
    var mockFetch: Fetch!
    
    func reset() {
        items.value = []
    }
    
    func fetch() {
        do {
            let newItems =  try mockFetch()
            items.value.append(contentsOf: newItems)
        }
        catch {
            errors.send(error.localizedDescription)
        }
    }
}
