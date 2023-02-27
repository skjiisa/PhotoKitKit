//
//  PhotoCollectionTests.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 2/26/23.
//

import XCTest
import Photos
@testable import PhotoKitKit

final class PhotoCollectionTests: XCTestCase {
    
    // MARK: Typealiases
    
    typealias SUT = PhotoCollection
    typealias Album = PhotoCollection.Album
    typealias Folder = PhotoCollection.Folder
    typealias CollectionFetcher = MockPHCollectionFetcher
    typealias CollectionFetchResults = MockCollectionFetchResult

    override func setUpWithError() throws {
        CollectionFetcher.reset()
        CollectionFetchResults.reset()
        SUT.collectionFetcher = CollectionFetcher.self
        Folder.collectionFetcher = CollectionFetcher.self
    }

    override func tearDownWithError() throws {
        CollectionFetcher.reset()
        CollectionFetchResults.reset()
        SUT.collectionFetcher = PHCollection.self
        Folder.collectionFetcher = PHCollection.self
    }
    
    // MARK: Init
    
    func testInitAlbum() {
        let mockAlbum = PHAssetCollection()
        let sut = SUT(mockAlbum)
        switch sut {
        case .album(let album):
            XCTAssertIdentical(album.phAlbum, mockAlbum)
        default:
            XCTFail("Not an album")
        }
    }
    
    func testInitFolder() {
        let mockFolder = PHCollectionList()
        let sut = SUT(mockFolder)
        switch sut {
        case .folder(let folder):
            XCTAssertIdentical(folder.phList, mockFolder)
        default:
            XCTFail("Not a folder")
        }
    }
    
    func testInitUnknown() {
        let mockCollection = PHCollection()
        let sut = SUT(mockCollection)
        switch sut {
        case .unknown(let collection):
            XCTAssertIdentical(collection, mockCollection)
        default:
            XCTFail("Not an unknown collection")
        }
    }
    
    // MARK: Children
    
    func testChildrenFolder() {
        let folder = Folder(PHCollectionList())
        let sut = SUT.folder(folder)
        // We don't need to test that the fetch occurs
        // correctly as that's tested in Folder's own tests
        XCTAssertIdentical(sut.lazyChildren?.fetchResults, CollectionFetcher._fetchCollectionsReturn)
    }
    
    func testChildrenNotFolder() {
        let sut = SUT(PHAssetCollection())
        XCTAssertNil(sut.children)
    }
    
    func testLazyChildrenFolder() {
        let albums = [PHCollection(), PHCollection(), PHCollection()]
        CollectionFetchResults._objects = albums
        
        let folder = Folder(PHCollectionList())
        let sut = SUT.folder(folder)
        let children = sut.children?.map { $0.phCollection }
        XCTAssertEqual(albums, children)
    }
    
    func testLazyChildrenNotFolder() {
        let sut = SUT(PHAssetCollection())
        XCTAssertNil(sut.lazyChildren)
    }
    
    // MARK: PHCollection
    
    func testPHCollection() {
        [
            PHAssetCollection(),
            PHCollectionList(),
            PHCollection(),
        ].forEach { XCTAssertIdentical(SUT($0).phCollection, $0) }
    }
    
    // MARK: Identifiable
    
    func testID() {
        let mockCollection = MockPHAssetCollection()
        let sut = SUT(mockCollection)
        XCTAssertEqual(mockCollection.localIdentifier, sut.id)
    }
    
    // MARK: Top-level Collections
    
    func testFetchTopLevelCollections() {
        let results = SUT.fetchTopLevelCollections()
        XCTAssertIdentical(results.fetchResults, CollectionFetcher._fetchTopLevelUserCollectionsReturn)
        // TODO: Test options once those are in
        XCTAssertNil(CollectionFetcher._fetchTopLevelUserCollectionsOptions)
    }
    
    func testGetTopLevelCollections() {
        let albums = [PHCollection(), PHCollection(), PHCollection()]
        CollectionFetchResults._objects = albums
        CollectionFetchResults._count = 3
        
        let results = SUT.getTopLevelCollections()
        (0..<3).forEach { i in XCTAssertIdentical(results[i].phCollection, albums[i]) }
        XCTAssertEqual(IndexSet(0..<CollectionFetchResults._count), CollectionFetchResults._objectsAtIndexes)
        // TODO: Test options once those are in
        XCTAssertNil(CollectionFetcher._fetchTopLevelUserCollectionsOptions)
    }
    
}
