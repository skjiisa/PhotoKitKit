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
    static var _objcets = [PHCollection]()
    override func objects(at indexes: IndexSet) -> [PHCollection] {
        Self._objectsAtIndexes = indexes
        return Self._objcets
    }
    
    static func reset() {
        _count = 0
        _objectsAtIndexes = nil
        _objcets.removeAll()
    }
}

// MARK: - MockPHCollectionFetcher

enum MockPHCollectionFetcher: PHCollectionFetcher {
    static var _fetchCollectionsCollectionList: PHCollectionList?
    static var _fetchCollectionsOptions: PHFetchOptions?
    static var _fetchCollectionsReturn: PHFetchResult<PHCollection>?
    static func fetchCollections(in collectionList: PHCollectionList, options: PHFetchOptions?) -> PHFetchResult<PHCollection> {
        _fetchCollectionsCollectionList = collectionList
        _fetchCollectionsOptions = options
        let result = MockCollectionFetchResult()
        _fetchCollectionsReturn = result
        return result
    }
    
    static func reset() {
        _fetchCollectionsCollectionList = nil
        _fetchCollectionsOptions = nil
        _fetchCollectionsReturn = nil
    }
}
