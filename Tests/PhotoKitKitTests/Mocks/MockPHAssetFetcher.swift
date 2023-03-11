//
//  MockPHAssetFetcher.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos
@testable import PhotoKitKit

// MARK: - MockAssetFetchResult

class MockAssetFetchResult: PHFetchResult<PHAsset> {
    static var _containsObject: PHAsset?
    static var _contains = false
    override func contains(_ anObject: PHAsset) -> Bool {
        Self._containsObject = anObject
        return Self._contains
    }
    
    var _count: Int = 0
    override var count: Int {
        _count
    }
    
    var _objectAtIndex: Int?
    var _objectAtIndexReturn = PHAsset()
    override func object(at index: Int) -> PHAsset {
        _objectAtIndex = index
        return _objectAtIndexReturn
    }
    
    func reset() {
        _count = 0
        _objectAtIndex = nil
        _objectAtIndexReturn = PHAsset()
        Self.reset()
    }
    
    static func reset() {
        _containsObject = nil
        _contains = false
    }
}

// MARK: - MockPHAssetFetcher

enum MockPHAssetFetcher: PHAssetFetcher {
    static var _fetchAssetsAssetCollection: PHAssetCollection?
    static var _fetchAssetsOptions: PHFetchOptions?
    static var _fetchAssetsReturn: PHFetchResult<PHAsset> = MockAssetFetchResult()
    static func fetchAssets(in assetCollection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        _fetchAssetsAssetCollection = assetCollection
        _fetchAssetsOptions = options
        return _fetchAssetsReturn
    }
    
    static func reset() {
        _fetchAssetsAssetCollection = nil
        _fetchAssetsOptions = nil
        _fetchAssetsReturn = MockAssetFetchResult()
    }
}
