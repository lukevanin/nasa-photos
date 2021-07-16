//
//  CollectionRepositoryTests.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
@testable import NASAPhotos

final class CollectionRepositoryTests: XCTestCase {
    
    // MARK: Fetch

    func testFetchShouldReturnCurrentValue() throws {
        let url = URL(string: "http://example.org")!
        let expected = [
            CollectionItem<PhotoEntity>(
                data: [
                    PhotoEntity(
                        nasaId: "foo-0",
                        dateCreated: Date(),
                        title: "Foo bar baz",
                        photographer: "Qux",
                        description: "Qik"
                    )
                ],
                links: [],
                href: WrappedURL(url: url)
            )
        ]
        let service = MockCodableGetService() { _ in
            XCTFail("Unexpected call to service")
        }
        let subject = CollectionRepository<PhotoEntity>(
            elements: expected,
            nextURL: url,
            service: service
        )
        let result = try wait(for: subject.fetch())
        XCTAssertEqual(result, expected)
    }
    
    // MARK: Next
    
    func testNextShouldReturnNextCollectionWhenNextReferencePresent() throws {
        let nextURL = URL(string: "http://example.org/next")!
        let elements = [
            CollectionItem<PhotoEntity>(
                data: [
                    PhotoEntity(
                        nasaId: "foo-0",
                        dateCreated: Date(),
                        title: "Foo bar baz",
                        photographer: "Qux",
                        description: "Qik"
                    )
                ],
                links: [],
                href: WrappedURL(
                    url: URL(string: "http://example.org/photo")!
                )
            )
        ]
        let service = MockCodableGetService() { url in
            XCTAssertEqual(url, nextURL)
            return CollectionResponseEntity(
                collection: CollectionEntity(
                    items: elements,
                    links: []
                )
            )
        }
        let expected = CollectionRepository<PhotoEntity>(
            elements: elements,
            nextURL: nil,
            service: service
        )
        let subject = CollectionRepository<PhotoEntity>(
            elements: [],
            nextURL: nextURL,
            service: service
        )
        let result = try wait(for: subject.next())
        XCTAssertEqual(result, expected)
    }
    
    func testNextShouldReturnNilWhenNextReferenceAbsent() throws {
        let service = MockCodableGetService() { url in
            XCTFail("Unexpected call to service")
        }
        let subject = CollectionRepository<PhotoEntity>(
            elements: [],
            nextURL: nil,
            service: service
        )
        let result = try wait(for: subject.next())
        XCTAssertNil(result)
    }
    
    func testNextShouldReturnErrorWhenCursorReturnsError() {
        let url = URL(string: "http://example.org")!
        let service = MockCodableGetService() { url in
            throw URLError(.badServerResponse)
        }
        let subject = CollectionRepository<PhotoEntity>(
            elements: [],
            nextURL: url,
            service: service
        )
        XCTAssertThrowsError(try wait(for: subject.next()))
    }

}
