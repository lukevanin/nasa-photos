//
//  PhotoDetailsModelTests.swift
//  NASAPhotosTests
//
//  Created by Luke Van In on 2021/07/19.
//

import XCTest
@testable import NASAPhotos

let manifestURL = URL(string: "https://example.org/manifest")!

let thumbURL = URL(string: "https://example.org/0~thumb.jpg")!
let smallURL = URL(string: "https://example.org/0~small.jpg")!
let mediumURL = URL(string: "https://example.org/0~medium.jpg")!
let originalURL = URL(string: "https://example.org/0~orig.jpg")!

final class NASAPhotoDetailsModelTests: XCTestCase {
    
    struct Scenario {
        let variants: [NASAPhotoDetailsModel.Variant]
        let manifest: [URL]
        let expectedURL: URL?
    }

    func testPhotoShouldNotIncludePreviewWhenManifestHasNoImageVariant() throws {
        let scenario = Scenario(
            variants: [.small, .medium, .original, .thumbnail],
            manifest: [],
            expectedURL: nil
        )
        try testScenarios([scenario])
    }

    func testPhotoShouldIncludePreviewWhenManifestHasMatchingImageVariant() throws {
        let scenarios: [Scenario] = [
            Scenario(
                variants: [.small, .medium, .original, .thumbnail],
                manifest: [mediumURL],
                expectedURL: mediumURL
            ),
            Scenario(
                variants: [.small, .medium, .original, .thumbnail],
                manifest: [smallURL],
                expectedURL: smallURL
            ),
            Scenario(
                variants: [.small, .medium, .original, .thumbnail],
                manifest: [thumbURL],
                expectedURL: thumbURL
            ),
            Scenario(
                variants: [.small, .medium, .original, .thumbnail],
                manifest: [originalURL],
                expectedURL: originalURL
            ),
            Scenario(
                variants: [.small, .medium, .original, .thumbnail],
                manifest: [originalURL, thumbURL],
                expectedURL: originalURL
            ),
        ]
        try testScenarios(scenarios)
    }

    func testPhotoShouldNotIncludePreviewWhenManifestHasNoMatchingImageVariant() throws {
        let scenarios: [Scenario] = [
            Scenario(
                variants: [.small, .medium, .original],
                manifest: [thumbURL],
                expectedURL: nil
            ),
            Scenario(
                variants: [.thumbnail, .medium, .original],
                manifest: [smallURL],
                expectedURL: nil
            ),
            Scenario(
                variants: [.thumbnail, .small, .original],
                manifest: [mediumURL],
                expectedURL: nil
            ),
            Scenario(
                variants: [.thumbnail, .small, .medium],
                manifest: [originalURL],
                expectedURL: nil
            ),
        ]
        try testScenarios(scenarios)
    }
    
    private func testScenarios(
        _ scenarios: [Scenario],
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let photo = NASAPhoto(
            id: "foo",
            manifestURL: manifestURL
        )
        for scenario in scenarios {
            let expected = NASAPhoto(
                id: photo.id,
                previewImageURL: scenario.expectedURL,
                manifestURL: manifestURL
            )
            let repository = MockAssetManifestRepository()
            repository.mockFetchManifest = { url in
                XCTAssertEqual(url, manifestURL)
                return scenario.manifest
            }
            let subject = NASAPhotoDetailsModel(
                photo: photo,
                previewImageVariants: scenario.variants,
                manifestRepository: repository
            )
            subject.reload()
            let result = try wait(for: subject.photo)
            XCTAssertEqual(result, expected, file: file, line: line)
        }
    }
}
