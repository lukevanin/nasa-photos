//
//  Helpers.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
import Combine


private var cancellables = Set<AnyCancellable>()


extension XCTestCase {
    
    func wait<P>(
        for publisher: P,
        timeout: TimeInterval = 1,
        description: String? = nil,
        file: StaticString = #file,
        line: Int = #line
    ) throws -> P.Output where P: Publisher {
        var output: Result<P.Output, P.Failure>?
        let expectation = expectation(description: description ?? "publisher")
        publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        output = .failure(error)
                        expectation.fulfill()
                    case .finished:
                        break
                    }
                },
                receiveValue: { value in
                    output = .success(value)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: timeout)
        guard let result = output else {
            throw XCTestError(.failureWhileWaiting)
        }
        return try result.get()
    }
}
