//
//  ListViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import Foundation
import Combine


///
///
///
protocol ListItemCoordinator {
    associatedtype Item
    
    func showItem(item: Item)
}

extension ListItemCoordinator {
    func eraseToAnyListItemCoordinator() -> AnyListItemCoordinator<Item> {
        AnyListItemCoordinator(self)
    }
}


///
///
///
final class AnyListItemCoordinator<Item> {
    
    typealias ShowItem = (Item) -> Void
    
    private let internalShowItem: ShowItem
    
    init<C>(_ coordinator: C) where C: ListItemCoordinator, C.Item == Item {
        self.internalShowItem = coordinator.showItem
    }
    
    func showItem(item: Item) {
        internalShowItem(item)
    }
}


///
///
///
final class ListViewModel<Input, Item>: ListViewModelProtocol where Item: Hashable {
    
    typealias Model = AnyPagedCollection<Input>
    typealias Transform = (Input) -> Item
    
    let items: AnyPublisher<[Item], Never>
    
    var errorCoordinator: ErrorCoordinatorProtocol?
    var itemCoordinator: AnyListItemCoordinator<Input>?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let model: Model
    
    init(model: Model, transform: @escaping Transform) {
        self.model = model
        self.items = model.elements
            .map { items in
                items.map(transform)
            }
            .eraseToAnyPublisher()
        
        // Observe the errors from the model, and show a prompt to retry the
        // request.
        model.errors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else {
                    return
                }
                self.showError(message: error.localizedDescription)
            }
            .store(in: &cancellables)
    }
    
    func reset() {
        model.reset()
    }
    
    func fetch() {
        model.fetch()
    }
    
    func selectItem(at index: Int) {
        #warning("TODO: Check that index is in range to avoid crash")
        let item = model.elements.value[index]
        itemCoordinator?.showItem(item: item)
    }
    
    private func showError(message: String) {
        #warning("TODO: Give up after a set number of retries")
        #warning("TODO: Only show cancel if the list is currently empty")
        errorCoordinator?.showError(
            message: message,
            cancellable: true,
            retry: { [weak self] in
                guard let self = self else {
                    return
                }
                self.model.fetch()
            }
        )
    }
}
