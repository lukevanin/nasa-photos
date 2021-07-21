//
//  PagedCollectionModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/19.
//

import Foundation
import Combine


///
/// Models a general purpose paginated collection of items. Uses a cursor to return batches of items from a
/// collection. Transforms input items into output items. Aggregates (combines together) separates batches of
/// items into a single collection containing all of the items.
///
final class PagedCollectionModel<Input, Output>: PagedCollectionProtocol {
    
    typealias Cursor = AnyCursor<[Input]>
    typealias Transform = (_ index: Int, _ item: Input) -> Output?
    
    let elements = CurrentValueSubject<[Output], Never>([])
    let errors = PassthroughSubject<Error, Never>()
    
    private var currentState: AnyModelState?
    
    private let initialCursor: Cursor
    private let transform: Transform
    
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
        elements.send([])
    }
    
    // MARK: Internal methods
    
    private func append(_ entities: [Input]) {
        var elements = self.elements.value
        let baseIndex = elements.count
        let newElements = entities
            .enumerated()
            .map { (index, element) in
                (baseIndex + index, element)
            }
            .compactMap(transform)
        elements.append(contentsOf: newElements)
        self.elements.send(elements)
    }
    
    // MARK: State management
    
    ///
    /// Base class used for all states implemented by the collection model.
    ///
    fileprivate class AnyModelState {
        weak var context: PagedCollectionModel!
        
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
    
    private func setState(_ state: AnyModelState) {
        currentState = state
        currentState?.context = self
        currentState?.enter()
    }
}
