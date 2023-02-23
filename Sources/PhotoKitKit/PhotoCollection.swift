//
//  PhotoCollection.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

// MARK: - PHAssetFetcher

public protocol PHAssetFetcher {
    static func fetchAssets(in assetCollection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset>
}

extension PHAsset: PHAssetFetcher { }

// MARK: - PhotoCollection

public enum PhotoCollection: PHFetchableWrapper, Hashable {
    case album(Album)
    case folder(Folder)
    case unknown(PHCollection)
    
    public var phCollection: PHCollection {
        switch self {
        case .album(let album):         return album.phAlbum
        case .folder(let folder):       return folder.phList
        case .unknown(let collection):  return collection
        }
    }
    
    public var children: [PhotoCollection]? {
        guard case .folder(let folder) = self else {
            return nil
        }
        return folder.getCollections()
    }
    
    public var lazyChildren: PHFetchResults<PhotoCollection>? {
        guard case .folder(let folder) = self else {
            return nil
        }
        return folder.fetchCollections()
    }
    
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

public extension PhotoCollection.Album {
    var title: String {
        phAlbum.localizedTitle ?? ""
    }
    
    func contains(_ asset: Asset) -> Bool {
        fetchAssets().fetchResults.contains(asset.phAsset)
    }
    
    func fetchAssets(fetcher: PHAssetFetcher.Type = PHAsset.self) -> PHFetchResults<Asset> {
        .init(fetcher.fetchAssets(in: phAlbum, options: nil))
    }
}

// MARK: Folder + Convenience

public extension PhotoCollection.Folder {
    var title: String {
        phList.localizedTitle ?? ""
    }
    
    func getCollections() -> [PhotoCollection] {
        PHCollection
            .fetchCollections(in: phList, options: nil)
            .allObjects()
            .compactMap(PhotoCollection.init)
    }
    
    func fetchCollections() -> PHFetchResults<PhotoCollection> {
        .init(PHCollection.fetchCollections(in: phList, options: nil))
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

public extension PhotoCollection {
    static func fetchTopLevelCollections() -> PHFetchResults<PhotoCollection> {
        .init(PHAssetCollection.fetchTopLevelUserCollections(with: nil))
    }
    
    static func getTopLevelCollections() -> [PhotoCollection] {
        PHAssetCollection
            .fetchTopLevelUserCollections(with: nil)
            .allObjects()
            .map(PhotoCollection.init)
    }
}
