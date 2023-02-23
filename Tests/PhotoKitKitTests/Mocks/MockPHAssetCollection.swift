//
//  MockPHAssetCollection.swift
//  
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

class MockPHAssetCollection: PHAssetCollection {
    var _localizedTitle: String?
    override var localizedTitle: String? {
        _localizedTitle
    }
}
