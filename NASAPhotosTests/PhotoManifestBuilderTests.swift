//
//  PhotoManifestBuilder.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
@testable import NASAPhotos

final class PhotoManifestBuilderTests: XCTestCase {

    let scenarios: [PhotoManifest.Variant : URL] = [
        .thumbnail: URL(string: "https://example.org/0~thumb.jpg")!,
        .small: URL(string: "https://example.org/0~small.jpg")!,
        .medium: URL(string: "https://example.org/0~medium.jpg")!,
        .original: URL(string: "https://example.org/0~orig.jpg")!,
    ]

    func testMakePhotoManifestReturnsOneVariantGivenOneUrl() {
        for (variant, url) in scenarios {
            let expected = PhotoManifest(
                assets: [
                    variant: url
                ]
            )
            let subject = PhotoManifestBuilder()
            let result = subject.makePhotoManifest(from: [url])
            XCTAssertEqual(result, expected)
        }
    }

    func testMakePhotoManifestReturnsAllVariantsGivenAllUrls() {
        let expected = PhotoManifest(
            assets: scenarios
        )
        let urls = scenarios.values.map { $0 }
        let subject = PhotoManifestBuilder()
        let result = subject.makePhotoManifest(from: urls)
        XCTAssertEqual(result, expected)
    }

    func testMakePhotoManifestReturnsNothingGivenUnsupportedUrl() {
        let url = URL(string: "https://example.org/0~foo.jpg")!
        let expected = PhotoManifest(assets: [:])
        let subject = PhotoManifestBuilder()
        let result = subject.makePhotoManifest(from: [url])
        XCTAssertEqual(result, expected)
    }

    func testMakePhotoManifestReturnsNothingGivenNoUrl() {
        let expected = PhotoManifest(assets: [:])
        let subject = PhotoManifestBuilder()
        let result = subject.makePhotoManifest(from: [])
        XCTAssertEqual(result, expected)
    }

}
