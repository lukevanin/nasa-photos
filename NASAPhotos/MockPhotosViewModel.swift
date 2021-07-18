//
//  MockPhotosViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import Foundation
import Combine


final class MockPhotosViewModel<Item>: ListViewModelProtocol where Item: Hashable {
    
    typealias Fetch = () -> [Item]
    typealias SelectItem = (Int) -> Void
    
    var items: AnyPublisher<[Item], Never>

    var fetchDelay = TimeInterval(1)
    var mockFetch: Fetch!
    var mockSelectItem: SelectItem!

    private var internalItems = CurrentValueSubject<[Item], Never>([])
    
    init() {
        self.items = internalItems.eraseToAnyPublisher()
    }

    func reset() {
        internalItems.value = []
    }
    
    func fetch() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + fetchDelay) { [weak self] in
            guard let self = self else {
                return
            }
            let newItems = self.mockFetch()
            self.internalItems.value.append(contentsOf: newItems)
        }
    }
    
    func selectItem(at index: Int) {
        mockSelectItem?(index)
    }

}
