//
//  MockPHChange.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 3/6/23.
//

import Photos
@testable import PhotoKitKit

class MockPHAssetFetchResultChangeDetails: PHFetchResultChangeDetails<PHAsset> {
    var _fetchResultAfterChanges = PHFetchResult<PHAsset>()
    override var fetchResultAfterChanges: PHFetchResult<PHAsset> {
        _fetchResultAfterChanges
    }
}

class MockPHChange: PHPhotoChange {
    var _changes: MockPHAssetFetchResultChangeDetails?
    func changeDetails<T>(for fetchResult: PHFetchResult<T>) -> PHFetchResultChangeDetails<T>? where T : PHObject {
        // TODO: Figure out a way to test that the correct fetchResult is passed in
        guard let tReturn = _changes as? PHFetchResultChangeDetails<T> else { return nil }
        return tReturn
    }
}
