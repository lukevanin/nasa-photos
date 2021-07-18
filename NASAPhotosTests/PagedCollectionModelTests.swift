//
//  PagedCollectionModelTests.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
@testable import NASAPhotos

final class PagedCollectionModelTests: XCTestCase {
    
    struct Dummy: Identifiable, Equatable {
        let id: String
    }
    
    typealias Cursor = MockCursor<[Dummy]>

    func testFetchShouldReturnDataWhenCurrentCursorReturnsData() throws {
        let entities = [
            Dummy(id: "foo")
        ]
        let cursor = Cursor(
            fetch: {
                XCTFail("Unexpected call to fetch")
                throw URLError(.cancelled)
            },
            next: {
                Cursor(
                    fetch: {
                        entities
                    }
                )
            }
        )
        let subject = PagedCollectionModel<Dummy, Dummy>(
            cursor: cursor.eraseToAnyCursor(),
            transform: { $1 }
        )
        subject.fetch()
        let result = try wait(for: subject.elements)
        XCTAssertEqual(result, entities)
    }

    func testFetchShouldReturnEmptyArrayWhenCursorReturnsNothing() throws {
        let cursor = Cursor(
            fetch: {
                XCTFail("Unexpected call to fetch")
                throw URLError(.cancelled)
            },
            next: {
                return nil
            }
        )
        let subject = PagedCollectionModel<Dummy, Dummy>(
            cursor: cursor.eraseToAnyCursor(),
            transform: { $1 }
        )
        subject.fetch()
        let result = try wait(for: subject.elements)
        XCTAssertEqual(result, [])
    }

    func testFetchShouldReturnEmptyArrayWhenCursorReturnsError() throws {
        let cursor = Cursor(
            fetch: {
                XCTFail("Unexpected call to fetch")
                throw URLError(.cancelled)
            },
            next: {
                throw URLError(.cancelled)
            }
        )
        let subject = PagedCollectionModel<Dummy, Dummy>(
            cursor: cursor.eraseToAnyCursor(),
            transform: { $1 }
        )
        subject.fetch()
        let result = try wait(for: subject.elements)
        XCTAssertEqual(result, [])
    }

    func testNextShouldFetchAgainWhenCursorReturnsError() throws {
        let nextExpectation = expectation(description: "next")
        nextExpectation.expectedFulfillmentCount = 2
        let cursor = Cursor(
            fetch: {
                XCTFail("Unexpected call to fetch")
                throw URLError(.cancelled)
            },
            next: {
                nextExpectation.fulfill()
                throw URLError(.cancelled)
            }
        )
        let subject = PagedCollectionModel<Dummy, Dummy>(
            cursor: cursor.eraseToAnyCursor(),
            transform: { $1 }
        )
        subject.fetch()
        let result = try wait(for: subject.elements)
        XCTAssertEqual(result, [])
        subject.fetch()
        wait(for: [nextExpectation], timeout: 1.0)
    }

    func testFetchShouldFetchAgainWhenCursorReturnsError() throws {
        let fetchExpectation = expectation(description: "fetch")
        fetchExpectation.expectedFulfillmentCount = 2
        let cursor = Cursor(
            fetch: {
                XCTFail("Unexpected call to fetch")
                throw URLError(.cancelled)
            },
            next: {
                Cursor(
                    fetch: {
                        fetchExpectation.fulfill()
                        throw URLError(.badServerResponse)
                    }
                )
            }
        )
        let subject = PagedCollectionModel<Dummy, Dummy>(
            cursor: cursor.eraseToAnyCursor(),
            transform: { $1 }
        )
        subject.fetch()
        let result = try wait(for: subject.elements)
        XCTAssertEqual(result, [])
        subject.fetch()
        wait(for: [fetchExpectation], timeout: 1.0)
    }

    func testFetchShouldReturnDataWhenWhenCursorReturnsErrorThenReturnsData() throws {
        var fetchCount = 0
        let entities = [
            Dummy(id: "foo")
        ]
        let cursor = Cursor(
            fetch: {
                XCTFail("Unexpected call to fetch")
                throw URLError(.cancelled)
            },
            next: {
                Cursor(
                    fetch: {
                        defer {
                            fetchCount += 1
                        }
                        if fetchCount == 0 {
                            throw URLError(.badServerResponse)
                        }
                        else {
                            return entities
                        }
                    }
                )
            }
        )
        let subject = PagedCollectionModel<Dummy, Dummy>(
            cursor: cursor.eraseToAnyCursor(),
            transform: { $1 }
        )
        subject.fetch()
        let result0 = try wait(for: subject.elements)
        XCTAssertEqual(result0, [])
        subject.fetch()
        let result1 = try wait(for: subject.elements)
        XCTAssertEqual(result1, entities)
        XCTAssertEqual(fetchCount, 2)
    }
    
    func testFetchTwiceShouldAppendDataWhenWhenCursorReturnsNextCursor() throws {
        let entity0 = Dummy(id: "foo")
        let entity1 = Dummy(id: "bar")
        let cursor = Cursor(
            fetch: {
                XCTFail("Unexpected call to fetch")
                throw URLError(.cancelled)
            },
            next: {
                Cursor(
                    fetch: {
                        [entity0]
                    },
                    next: {
                        Cursor(
                            fetch: {
                                [entity1]
                            }
                        )
                    }
                )
            }
        )
        let subject = PagedCollectionModel<Dummy, Dummy>(
            cursor: cursor.eraseToAnyCursor(),
            transform: { $1 }
        )
        subject.fetch()
        let result0 = try wait(for: subject.elements)
        XCTAssertEqual(result0, [entity0])
        subject.fetch()
        let result1 = try wait(for: subject.elements)
        XCTAssertEqual(result1, [entity0, entity1])
    }
}
