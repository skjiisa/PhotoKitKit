//
//  FolderTests.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 2/26/23.
//

import XCTest
import Photos
@testable import PhotoKitKit

final class FolderTests: XCTestCase {
    
    // MARK: Typealiases
    
    typealias SUT = PhotoCollection.Folder
    typealias MockFolder = MockPHCollectionList
    typealias CollectionFetcher = MockPHCollectionFetcher
    typealias CollectionFetchResults = MockCollectionFetchResult
    
    // MARK: Setup

    override func setUpWithError() throws {
        CollectionFetcher.reset()
        CollectionFetchResults.reset()
        SUT.collectionFetcher = CollectionFetcher.self
    }

    override func tearDownWithError() throws {
        CollectionFetcher.reset()
        CollectionFetchResults.reset()
        SUT.collectionFetcher = PHCollection.self
    }
    
    // MARK: Title

    func testTitle() {
        let mockAssetCollection = MockFolder()
        let expectedTitle = UUID().uuidString
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, expectedTitle)
    }
    
    func testTitleNilLocalizedTitle() {
        let mockAssetCollection = MockFolder()
        let expectedTitle: String? = nil
        mockAssetCollection._localizedTitle = expectedTitle
        
        let sut = SUT(mockAssetCollection)
        XCTAssertEqual(sut.title, "")
    }
    
    // MARK: Get Collections
    
    func testGetCollections() {
        let albums = [PHCollection(), PHCollection(), PHCollection()]
        CollectionFetchResults._objcets = albums
        CollectionFetchResults._count = 3
        
        let sut = SUT(PHCollectionList())
        
        let result = sut.getCollections()
        (0..<3).forEach { i in XCTAssertIdentical(result[i].phCollection, albums[i]) }
        XCTAssertEqual(IndexSet(0..<CollectionFetchResults._count), CollectionFetchResults._objectsAtIndexes)
    }
    
    // MARK: Fetch Collections
    
    func testFetchCollections() {
        let folder = PHCollectionList()
        let sut = SUT(folder)
        
        let result = sut.fetchCollections()
        XCTAssertIdentical(result.fetchResults, CollectionFetcher._fetchCollectionsReturn)
        XCTAssertIdentical(folder, CollectionFetcher._fetchCollectionsCollectionList)
        // TODO: Test options once those are in
        XCTAssertNil(CollectionFetcher._fetchCollectionsOptions)
    }
    
    // MARK: Identifiable
    
    func testID() {
        let mockFolder = MockFolder()
        let sut = SUT(mockFolder)
        XCTAssertEqual(mockFolder.localIdentifier, sut.id)
    }

}
