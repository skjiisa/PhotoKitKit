//
//  File.swift
//  
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos
@testable import PhotoKitKit

enum MockPHAssetFetcher: PHAssetFetcher {
    static var _fetchAssetsAssetCollection: PHAssetCollection?
    static var _fetchAssetsOptions: PHFetchOptions?
    static var _fetchAssetsReturn: PHFetchResult<PHAsset>?
    static func fetchAssets(in assetCollection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        _fetchAssetsAssetCollection = assetCollection
        _fetchAssetsOptions = options
        let result = PHFetchResult<PHAsset>()
        _fetchAssetsReturn = result
        return result
    }
    
    static func reset() {
        _fetchAssetsAssetCollection = nil
        _fetchAssetsOptions = nil
        _fetchAssetsReturn = nil
    }
}
