//
//  PhotoKit+Extensions.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

// MARK: - PhotoKit Extensions

extension PHFetchResult {
    @objc func allObjects() -> [ObjectType] {
        objects(at: IndexSet(0..<count))
    }
}

extension PHObject: Identifiable {
    public var id: String {
        localIdentifier
    }
}

extension PHAsset {
    // TODO: What if the asset is deleted?
    // Should that return `nil`
    func reload() -> PHAsset {
        PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject ?? self
    }
}
