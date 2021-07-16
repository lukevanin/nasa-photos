//
//  PhotoBuilderTests.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/16.
//

import XCTest
@testable import NASAPhotos

final class PhotoBuilderTests: XCTestCase {

    func testMakePhotoShouldReturnPhotoWhenEntityHasData() {
        let expected = Photo(
            id: "foo",
            title: "bar",
            dateCreated: Date(timeIntervalSince1970: 3600),
            photographer: "baz",
            details: "qux",
            thumbnailImageURL: URL(string: "http://example.org/foo/image~thumb.jpg")!,
            manifestURL: URL(string: "http://example.org/foo/manifest")!
        )
        let entity = CollectionItem(
            data: [
                PhotoEntity(
                    nasaId: expected.id,
                    dateCreated: expected.dateCreated!,
                    title: expected.title,
                    photographer: expected.photographer,
                    description: expected.details
                ),
            ],
            links: [
                LinkEntity(
                    href: WrappedURLEntity(
                        url: expected.thumbnailImageURL!
                    ),
                    rel: .preview
                )
            ],
            href: WrappedURLEntity(
                url: expected.manifestURL!
            )
        )
        let subject = PhotoBuilder()
        let result = subject.makePhoto(for: entity)
        XCTAssertEqual(result, expected)
    }
    
    func testMakePhotoShouldReturnPhotoWithoutThumbnailWhenEntityHasNoPreviewLink() {
        let expected = Photo(
            id: "foo",
            title: "bar",
            dateCreated: Date(timeIntervalSince1970: 3600),
            photographer: "baz",
            details: "qux",
            thumbnailImageURL: nil,
            manifestURL: URL(string: "http://example.org/foo/manifest")!
        )
        let entity = CollectionItem(
            data: [
                PhotoEntity(
                    nasaId: expected.id,
                    dateCreated: expected.dateCreated!,
                    title: expected.title,
                    photographer: expected.photographer,
                    description: expected.details
                ),
            ],
            links: [],
            href: WrappedURLEntity(
                url: expected.manifestURL!
            )
        )
        let subject = PhotoBuilder()
        let result = subject.makePhoto(for: entity)
        XCTAssertEqual(result, expected)
    }
    
    func testMakePhotoShouldReturnNilWhenEntityHasNoData() {
        let entity = CollectionItem<PhotoEntity>(
            data: [],
            links: [
                LinkEntity(
                    href: WrappedURLEntity(
                        url: URL(string: "http://example.org/foo/image~thumb.jpg")!
                    ),
                    rel: .preview
                )
            ],
            href: WrappedURLEntity(
                url: URL(string: "http://example.org/foo/manifest")!
            )
        )
        let subject = PhotoBuilder()
        let result = subject.makePhoto(for: entity)
        XCTAssertNil(result)
    }

}
