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
