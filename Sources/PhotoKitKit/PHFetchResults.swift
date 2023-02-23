//
//  PHFetchResults.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

// MARK: - PHFetchableWrapper

public protocol PHFetchableWrapper {
    associatedtype Wrapped: PHObject
    init(_: Wrapped)
}

// MARK: - PHFetchResults

public struct PHFetchResults<Wrapper: PHFetchableWrapper>: Hashable {
    typealias FetchResults = PHFetchResult<Wrapper.Wrapped>
    var fetchResults: FetchResults
    
    init(_ fetchResults: FetchResults) {
        self.fetchResults = fetchResults
    }
}

// MARK: - RandomAccessCollection

extension PHFetchResults: RandomAccessCollection {
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        fetchResults.count
    }
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public subscript(position: Int) -> Wrapper {
        // PHFetchResults is a class and I believe it has its own cache, so
        // I don't need to worry about caching stuff in AssetResults itself
        Wrapper(fetchResults.object(at: position))
    }
}
