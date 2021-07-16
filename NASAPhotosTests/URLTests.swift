//
//  URLTests.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
@testable import NASAPhotos

final class URLTests: XCTestCase {

    func testUsingHttpsReturnsHttpsSchemeWhenGivenHttpUrlScheme() {
        let subject = URL(string: "http://example.org")!
        let expected = URL(string: "https://example.org")!
        let result = subject.usingHTTPS()
        XCTAssertEqual(result, expected)
    }

    func testUsingHttpsReturnsHttpsSchemeWhenGivenHttpsUrlScheme() {
        let subject = URL(string: "https://example.org")!
        let expected = URL(string: "https://example.org")!
        let result = subject.usingHTTPS()
        XCTAssertEqual(result, expected)
    }
}
