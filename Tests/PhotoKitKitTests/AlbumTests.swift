//
//  AlbumTests.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 2/22/23.
//

import XCTest
import Photos
@testable import PhotoKitKit

final class AlbumTests: XCTestCase {
    
    // MARK: Type Aliases
    
    typealias SUT = PhotoCollection.Album
    
    // MARK: Setup

    override func setUpWithError() throws {
        MockPHAssetFetcher.reset()
    }

    override func tearDownWithError() throws {
        MockPHAssetFetcher.reset()
    }
    
    // MARK: Album + Convenience

    func testAlbumTitle() {
        let mockAssetCollection = MockPHAssetCollection()
        let expectedTitle = UUID().uuidString
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, expectedTitle)
    }
    
    func testAlbumTitleNilLocalizedTitle() {
        let mockAssetCollection = MockPHAssetCollection()
        let expectedTitle: String? = nil
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, "")
    }
    
    func testFetchAssets() {
        let mockAssetFetcher = MockPHAssetFetcher.self
        let album = PHAssetCollection()
        let sut = PhotoCollection.Album(album)
        
        let result = sut.fetchAssets(fetcher: mockAssetFetcher)
        XCTAssertIdentical(result.fetchResults, MockPHAssetFetcher._fetchAssetsReturn)
        XCTAssertIdentical(mockAssetFetcher._fetchAssetsAssetCollection, album)
        // TODO: Test options once those are in
    }

}
