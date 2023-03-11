//
//  MockPHCollectionFetcher.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 2/26/23.
//

import Photos
@testable import PhotoKitKit

// MARK: - MockCollectionFetchResult

class MockCollectionFetchResult: PHFetchResult<PHCollection> {
    static var _count: Int = 0
    override var count: Int {
        Self._count
    }
    
    static var _objectsAtIndexes: IndexSet?
    static var _objects = [PHCollection]()
    override func objects(at indexes: IndexSet) -> [PHCollection] {
        Self._objectsAtIndexes = indexes
        return Self._objects
    }
    
    static func reset() {
        _count = 0
        _objectsAtIndexes = nil
        _objects.removeAll()
    }
}

// MARK: - MockPHCollectionFetcher

enum MockPHCollectionFetcher: PHCollectionFetcher {
    static var _fetchCollectionsCollectionList: PHCollectionList?
    static var _fetchCollectionsOptions: PHFetchOptions?
    static var _fetchCollectionsReturn: PHFetchResult<PHCollection> = MockCollectionFetchResult()
    static func fetchCollections(in collectionList: PHCollectionList, options: PHFetchOptions?) -> PHFetchResult<PHCollection> {
        _fetchCollectionsCollectionList = collectionList
        _fetchCollectionsOptions = options
        return _fetchCollectionsReturn
    }
    
    static var _fetchTopLevelUserCollectionsOptions: PHFetchOptions?
    static var _fetchTopLevelUserCollectionsReturn: PHFetchResult<PHCollection> = MockCollectionFetchResult()
    static func fetchTopLevelUserCollections(with options: PHFetchOptions?) -> PHFetchResult<PHCollection> {
        _fetchTopLevelUserCollectionsOptions = options
        return _fetchTopLevelUserCollectionsReturn
    }
    
    static func reset() {
        _fetchCollectionsCollectionList = nil
        _fetchCollectionsOptions = nil
        _fetchCollectionsReturn = MockCollectionFetchResult()
        
        _fetchTopLevelUserCollectionsOptions = nil
        _fetchTopLevelUserCollectionsReturn = MockCollectionFetchResult()
    }
}
