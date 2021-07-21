//
//  PagedCollectionProtocol.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation
import Combine


///
///
///
protocol PagedCollectionProtocol {
    
    associatedtype Output
    
    var elements: CurrentValueSubject<[Output], Never> { get }
    var errors: PassthroughSubject<Error, Never> { get }

    func fetch()
    func cancel()
    func reset()
}

extension PagedCollectionProtocol {
    func eraseToAnyCollection() -> AnyPagedCollection<Output> {
        AnyPagedCollection(self)
    }
}


///
///
///
struct AnyPagedCollection<Output> {
    
    let elements: CurrentValueSubject<[Output], Never>
    let errors: PassthroughSubject<Error, Never>
    
    private var internalFetch: () -> Void
    private var internalCancel: () -> Void
    private var internalReset: () -> Void

    init<C>(_ collection: C) where C: PagedCollectionProtocol, C.Output == Output {
        self.elements = collection.elements
        self.errors = collection.errors
        self.internalFetch = collection.fetch
        self.internalCancel = collection.cancel
        self.internalReset = collection.reset
    }
    
    func fetch() {
        internalFetch()
    }
    
    func cancel() {
        internalCancel()
    }
    
    func reset() {
        internalReset()
    }
}
