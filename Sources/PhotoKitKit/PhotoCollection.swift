//
//  PhotoCollection.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

// MARK: - Dependencies

protocol PHAssetFetcher {
    static func fetchAssets(in assetCollection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset>
}

extension PHAsset: PHAssetFetcher { }

protocol PHCollectionFetcher {
    static func fetchCollections(in collectionList: PHCollectionList, options: PHFetchOptions?) -> PHFetchResult<PHCollection>
    static func fetchTopLevelUserCollections(with options: PHFetchOptions?) -> PHFetchResult<PHCollection>
}

extension PHCollection: PHCollectionFetcher { }

// MARK: - PhotoCollection

public enum PhotoCollection: PHFetchableWrapper, Hashable {
    case album(Album)
    case folder(Folder)
    case unknown(PHCollection)
    
    public init(_ phCollection: PHCollection) {
        if let album = phCollection as? PHAssetCollection {
            self = .album(Album(album))
        } else if let folder = phCollection as? PHCollectionList {
            self = .folder(Folder(folder))
        } else {
            // PhotoKit should only return PHAssetCollection or PHCollectionList,
            // but PHCollection could technically have other subclasses, and I'd
            // rather keep this type-safe than need to force unwrap.
            self = .unknown(phCollection)
        }
    }
    
    public var phCollection: PHCollection {
        switch self {
        case .album(let album):         return album.phAlbum
        case .folder(let folder):       return folder.phList
        case .unknown(let collection):  return collection
        }
    }
    
    public var lazyChildren: PHFetchResults<PhotoCollection>? {
        guard case .folder(let folder) = self else {
            return nil
        }
        // TODO: Add options through a stored property?
        return folder.fetchCollections()
    }
    
    public var children: [PhotoCollection]? {
        guard case .folder(let folder) = self else {
            return nil
        }
        return folder.getCollections()
    }
}

public extension PhotoCollection {
    
    // MARK: Album
    
    struct Album: PHFetchableWrapper, Hashable {
        public var phAlbum: PHAssetCollection
        
        public init(_ phAlbum: PHAssetCollection) {
            self.phAlbum = phAlbum
        }
    }
    
    // MARK: Folder
    
    struct Folder: Hashable {
        public var phList: PHCollectionList
        
        public init(_ phList: PHCollectionList) {
            self.phList = phList
        }
    }
}

// MARK: Album + Convenience

extension PhotoCollection.Album {
    static var assetFetcher: PHAssetFetcher.Type = PHAsset.self
    
    public var title: String {
        phAlbum.localizedTitle ?? ""
    }
    
    public func contains(_ asset: Asset) -> Bool {
        fetchAssets().fetchResults.contains(asset.phAsset)
    }
    
    public func fetchAssets() -> PHFetchResults<Asset> {
        .init(Self.assetFetcher.fetchAssets(in: phAlbum, options: nil))
    }
}

// MARK: Folder + Convenience

extension PhotoCollection.Folder {
    static var collectionFetcher: PHCollectionFetcher.Type = PHCollection.self
    
    public var title: String {
        phList.localizedTitle ?? ""
    }
    
    public func fetchCollections() -> PHFetchResults<PhotoCollection> {
        .init(Self.collectionFetcher.fetchCollections(in: phList, options: nil))
    }
    
    public func getCollections() -> [PhotoCollection] {
        Self.collectionFetcher
            .fetchCollections(in: phList, options: nil)
            .allObjects()
            .compactMap(PhotoCollection.init)
    }
}

// MARK: - Identifiable

extension PhotoCollection: Identifiable {
    public var id: String {
        phCollection.id
    }
}

extension PhotoCollection.Album: Identifiable {
    public var id: String {
        phAlbum.id
    }
}

extension PhotoCollection.Folder: Identifiable {
    public var id: String {
        phList.id
    }
}

// MARK: - Static

extension PhotoCollection {
    static var collectionFetcher: PHCollectionFetcher.Type = PHCollection.self
    
    public static func fetchTopLevelCollections() -> PHFetchResults<PhotoCollection> {
        .init(collectionFetcher.fetchTopLevelUserCollections(with: nil))
    }
    
    public static func getTopLevelCollections() -> [PhotoCollection] {
        collectionFetcher
            .fetchTopLevelUserCollections(with: nil)
            .allObjects()
            .map(PhotoCollection.init)
    }
}
