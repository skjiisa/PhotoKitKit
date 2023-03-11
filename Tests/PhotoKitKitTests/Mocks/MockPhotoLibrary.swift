//
//  MockPhotoLibrary.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 3/6/23.
//

import Photos
@testable import PhotoKitKit

class MockPhotoLibrary: PhotoLibrary {
    var _registerObserver: PHPhotoLibraryChangeObserver?
    func register(_ observer: PHPhotoLibraryChangeObserver) {
        _registerObserver = observer
    }
}
