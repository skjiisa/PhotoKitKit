//
//  File.swift
//  
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos
@testable import PhotoKitKit

class MockAssetFetchResult: PHFetchResult<PHAsset> {
    static var _containsObject: PHAsset?
    static var _contains = false
    override func contains(_ anObject: PHAsset) -> Bool {
        Self._containsObject = anObject
        return Self._contains
    }
    
    static func reset() {
        _containsObject = nil
        _contains = false
    }
}

enum MockPHAssetFetcher: PHAssetFetcher {
    static var _fetchAssetsAssetCollection: PHAssetCollection?
    static var _fetchAssetsOptions: PHFetchOptions?
    static var _fetchAssetsReturn: PHFetchResult<PHAsset>?
    static func fetchAssets(in assetCollection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        _fetchAssetsAssetCollection = assetCollection
        _fetchAssetsOptions = options
        let result = MockAssetFetchResult()
        _fetchAssetsReturn = result
        return result
    }
    
    static func reset() {
        _fetchAssetsAssetCollection = nil
        _fetchAssetsOptions = nil
        _fetchAssetsReturn = nil
    }
}
