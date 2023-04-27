//
//  PHFetchResults.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

// MARK: - PHFetchableWrapper

public protocol PHFetchableWrapper: Hashable {
    associatedtype Wrapped: PHObject
    init(_: Wrapped)
}

// MARK: - PHFetchResults

public struct PHFetchResults<Wrapper: PHFetchableWrapper>: RandomAccessCollection {
    typealias FetchResults = PHFetchResult<Wrapper.Wrapped>
    var fetchResults: FetchResults {
        didSet {
            cache.clear()
        }
    }
    
    private var cache: Cache
    
    fileprivate class Cache {
        private var items: [Wrapper?]
        
        private init(items: [Wrapper?]) {
            self.items = items
        }
    }
    
    // MARK: RandomAccessCollection
    
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        fetchResults.count
    }
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    // There is no point in caching when Wrapper is a struct
    // (which will be copied on each read anyway) since
    // PHFetchResult handles its own caching of the PHObjects
    // themselves. As a result, subscript is defined differently
    // in extensions depending on if Wrapper is a class or not.
}

// MARK: - Wrapper is a class

extension PHFetchResults where Wrapper: AnyObject {
    init(_ fetchResults: FetchResults) {
        self.fetchResults = fetchResults
        self.cache = Cache(items: fetchResults.count)
    }
    
    public subscript(position: Int) -> Wrapper {
        cache.item(at: position, defaultValue: fetchResults.object(at: position))
    }
}

extension PHFetchResults.Cache where Wrapper: AnyObject {
    convenience init(items: Int) {
        self.init(items: [Wrapper?](repeating: nil, count: items))
    }
    
    func item(at index: Int, defaultValue: @autoclosure () -> Wrapper.Wrapped) -> Wrapper {
        guard items.indices.contains(index) else {
            // Initialization did not occur properly so the
            // array is not large enough. Should never happen.
            return Wrapper(defaultValue())
        }
        
        return items[index] ?? {
            let item = Wrapper(defaultValue())
            items[index] = item
            return item
        }()
    }
    
    func clear() {
        items.removeAll(keepingCapacity: true)
    }
}

// MARK: - Wrapper is a struct

extension PHFetchResults /* where Wrapper is a struct */ {
    init(_ fetchResults: FetchResults) {
        self.fetchResults = fetchResults
        self.cache = Cache()
    }
    
    public subscript(position: Int) -> Wrapper {
        // PHFetchResult is a class and has its own cache, so we
        // don't need to worry about caching stuff ourselves.
        Wrapper(fetchResults.object(at: position))
    }
}

extension PHFetchResults.Cache /* where Wrapper is a struct */ {
    convenience init() {
        self.init(items: [])
    }
    
    func clear() { }
}
