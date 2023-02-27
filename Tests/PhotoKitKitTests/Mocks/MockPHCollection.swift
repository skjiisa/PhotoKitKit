//
//  MockPHCollection.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

// MARK: - MockPHAssetCollection

class MockPHAssetCollection: PHAssetCollection {
    var _localIdentifier: String = UUID().uuidString
    override var localIdentifier: String {
        _localIdentifier
    }
    
    var _localizedTitle: String?
    override var localizedTitle: String? {
        _localizedTitle
    }
}

// MARK: - MockPHCollectionList

class MockPHCollectionList: PHCollectionList {
    var _localIdentifier: String = UUID().uuidString
    override var localIdentifier: String {
        _localIdentifier
    }
    
    var _localizedTitle: String?
    override var localizedTitle: String? {
        _localizedTitle
    }
}
