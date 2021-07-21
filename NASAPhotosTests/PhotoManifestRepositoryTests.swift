//
//  PhotoManifestRepositoryTests.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
@testable import NASAPhotos

final class PhotoManifestRepositoryTests: XCTestCase {

//    func testFetchShouldReturnManifestWhenServiceReturnsEntity() throws {
//        let manifestURL = URL(string: "https://example.org/manifest")!
//        let expected = PhotoManifest(
//            assets: [
//                .thumbnail: URL(string: "https://example.org/0~thumb.jpg")!
//            ]
//        )
//        let service = MockCodableGetService() { url in
//            XCTAssertEqual(url, manifestURL)
//            return [
//                WrappedURLEntity(
//                    url: URL(string: "https://example.org/0~thumb.jpg")!
//                )
//            ]
//        }
//        let subject = PhotoManifestRepository(service: service)
//        let operation = subject.fetchManifest(for: manifestURL)
//        let result = try wait(for: operation)
//        XCTAssertEqual(result, expected)
//    }
//    
//    func testFetchShouldReturnErrorWhenServiceReturnsError() {
//        let manifestURL = URL(string: "https://example.org/manifest")!
//        let service = MockCodableGetService() { url in
//            XCTAssertEqual(url, manifestURL)
//            throw(URLError(.badServerResponse))
//        }
//        let subject = PhotoManifestRepository(service: service)
//        let operation = subject.fetchManifest(for: manifestURL)
//        XCTAssertThrowsError(try wait(for: operation))
//    }

}
