//
//  WrappedURLTests.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
@testable import NASAPhotos

final class WrappedURLEntityTests: XCTestCase {

    func testDecodeShouldEscapeUnsafeCharacters() throws {
        let input = "\"http://example.org/foo bar\""
        let expected = WrappedURLEntity(
            url: URL(string: "http://example.org/foo%20bar")!
        )
        let decoder = JSONDecoder()
        let data = input.data(using: .utf8)!
        let output = try decoder.decode(WrappedURLEntity.self, from: data)
        XCTAssertEqual(output, expected)
    }
}
