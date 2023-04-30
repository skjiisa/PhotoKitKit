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
    
    private typealias SUT = PhotoCollection.Album
    private typealias MockAlbum = MockPHAssetCollection
    private typealias AssetFetcher = MockPHAssetFetcher
    private typealias AssetFetchResults = MockAssetFetchResult
    
    // MARK: Setup

    override func setUpWithError() throws {
        AssetFetcher.reset()
        AssetFetchResults.reset()
        SUT.assetFetcher = AssetFetcher.self
    }

    override func tearDownWithError() throws {
        AssetFetcher.reset()
        AssetFetchResults.reset()
        SUT.assetFetcher = PHAsset.self
    }
    
    // MARK: Title

    func testTitle() {
        let mockAssetCollection = MockAlbum()
        let expectedTitle = UUID().uuidString
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, expectedTitle)
    }
    
    func testTitleNilLocalizedTitle() {
        let mockAssetCollection = MockAlbum()
        let expectedTitle: String? = nil
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, "")
    }
    
    // MARK: Contains
    
    func testContains() {
        let mockAsset = StaticAsset(PHAsset())
        
        let sut = SUT(PHAssetCollection())
        
        let expectedResult = true
        AssetFetchResults._contains = expectedResult
        let actualResult = sut.contains(mockAsset)
        XCTAssertEqual(actualResult, expectedResult)
        XCTAssertIdentical(AssetFetchResults._containsObject, mockAsset.phAsset)
    }
    
    func testDoesNotContain() {
        let mockAsset = StaticAsset(PHAsset())
        
        let sut = SUT(PHAssetCollection())
        
        let expectedResult = false
        AssetFetchResults._contains = expectedResult
        let actualResult = sut.contains(mockAsset)
        XCTAssertEqual(actualResult, expectedResult)
        XCTAssertIdentical(AssetFetchResults._containsObject, mockAsset.phAsset)
    }
    
    // MARK: Fetch Assets
    
    func testFetchAssets() {
        let album = PHAssetCollection()
        let sut = SUT(album)
        
        let results = sut.fetchAssets()
        XCTAssertIdentical(results.fetchResults, AssetFetcher._fetchAssetsReturn)
        XCTAssertIdentical(album, AssetFetcher._fetchAssetsAssetCollection)
        // TODO: Test options once those are in
        XCTAssertNil(AssetFetcher._fetchAssetsOptions)
    }
    
    // MARK: Identifiable
    
    func testID() {
        let mockAlbum = MockAlbum()
        let sut = SUT(mockAlbum)
        XCTAssertEqual(mockAlbum.localIdentifier, sut.id)
    }

}
