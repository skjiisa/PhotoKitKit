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
    typealias AssetFetcher = MockPHAssetFetcher
    typealias AssetFetchResults = MockAssetFetchResult
    
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
    
    // MARK: Convenience

    func testTitle() {
        let mockAssetCollection = MockPHAssetCollection()
        let expectedTitle = UUID().uuidString
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, expectedTitle)
    }
    
    func testTitleNilLocalizedTitle() {
        let mockAssetCollection = MockPHAssetCollection()
        let expectedTitle: String? = nil
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, "")
    }
    
    func testContains() {
        let mockAsset = Asset(PHAsset())
        
        let sut = SUT(PHAssetCollection())
        
        let expectedResult = true
        AssetFetchResults._contains = expectedResult
        let actualResult = sut.contains(mockAsset)
        XCTAssertEqual(actualResult, expectedResult)
        XCTAssertIdentical(AssetFetchResults._containsObject, mockAsset.phAsset)
    }
    
    func testDoesNotContain() {
        let mockAsset = Asset(PHAsset())
        
        let sut = SUT(PHAssetCollection())
        
        let expectedResult = false
        AssetFetchResults._contains = expectedResult
        let actualResult = sut.contains(mockAsset)
        XCTAssertEqual(actualResult, expectedResult)
        XCTAssertIdentical(AssetFetchResults._containsObject, mockAsset.phAsset)
    }
    
    func testFetchAssets() {
        let album = PHAssetCollection()
        let sut = PhotoCollection.Album(album)
        
        let result = sut.fetchAssets()
        XCTAssertIdentical(result.fetchResults, MockPHAssetFetcher._fetchAssetsReturn)
        XCTAssertIdentical(AssetFetcher._fetchAssetsAssetCollection, album)
        // TODO: Test options once those are in
    }

}
