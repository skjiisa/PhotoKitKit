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
    
    private typealias SUT = PhotoCollection.Folder
    private typealias MockFolder = MockPHCollectionList
    private typealias CollectionFetcher = MockPHCollectionFetcher
    private typealias CollectionFetchResults = MockCollectionFetchResult
    
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
    
    // MARK: Loading Collections
    
    func testFetchCollections() {
        let folder = PHCollectionList()
        let sut = SUT(folder)
        
        let results = sut.fetchCollections()
        XCTAssertIdentical(results.fetchResults, CollectionFetcher._fetchCollectionsReturn)
        XCTAssertIdentical(folder, CollectionFetcher._fetchCollectionsCollectionList)
        // TODO: Test options once those are in
        XCTAssertNil(CollectionFetcher._fetchCollectionsOptions)
    }
    
    func testGetCollections() {
        let albums = [PHCollection(), PHCollection(), PHCollection()]
        CollectionFetchResults._objects = albums
        CollectionFetchResults._count = 3
        
        let sut = SUT(PHCollectionList())
        
        let results = sut.getCollections()
        (0..<3).forEach { i in XCTAssertIdentical(results[i].phCollection, albums[i]) }
        XCTAssertEqual(IndexSet(0..<CollectionFetchResults._count), CollectionFetchResults._objectsAtIndexes)
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
