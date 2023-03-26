//
//  Asset.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
public typealias UIImage = NSImage
#endif

// MARK: - Asset

public struct Asset: Hashable, PHFetchableWrapper {
    public let phAsset: PHAsset
    
    public init(_ phAsset: PHAsset) {
        self.phAsset = phAsset
    }
}

// MARK: - Identifiable

extension Asset: Identifiable {
    public var id: String {
        phAsset.id
    }
}

// MARK: - Convenience

public extension Asset {
    
    // MARK: Albums
    
    //TODO: Options
    func fetchAllAlbums() -> PHFetchResults<PhotoCollection.Album> {
        .init(PHAssetCollection.fetchAssetCollectionsContaining(phAsset, with: .album, options: nil))
    }
    
    func getAllAlbums() -> [PhotoCollection.Album] {
        PHAssetCollection
            .fetchAssetCollectionsContaining(phAsset, with: .album, options: nil)
            .allObjects()
            .map(PhotoCollection.Album.init)
    }
    
    enum PreviewInfo: Hashable {
        case cloud
        case thumbnail
        case requestID(Int)
        case canceled
    }
    
    // MARK: Image Data
    
    func getFullSizePreviewImage(
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<UIImage, Error>, Set<PreviewInfo>) -> Void
    ) {
        getPreviewImage(targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: resultHandler)
    }
    
    // TODO: Create async wrappers for these
    func getPreviewImage(
        targetSize: CGSize,
        contentMode: PHImageContentMode,
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<UIImage, Error>, Set<PreviewInfo>) -> Void
    ) {
        PHImageManager.default().requestImage(for: phAsset, targetSize: targetSize, contentMode: contentMode, options: nil) { image, infoDictionary in
            var info = Set<PreviewInfo>()
            
            if let isInCloud = infoDictionary?[PHImageResultIsInCloudKey] as? NSNumber,
               isInCloud.boolValue {
                info.insert(.cloud)
            }
            
            if let isDegraded = infoDictionary?[PHImageResultIsDegradedKey] as? NSNumber,
               isDegraded.boolValue {
                info.insert(.cloud)
            }
            
            if let requestID = infoDictionary?[PHImageResultRequestIDKey] as? NSNumber {
                info.insert(.requestID(requestID.intValue))
            }
            
            if let isCanceled = infoDictionary?[PHImageCancelledKey] as? NSNumber,
               isCanceled.boolValue {
                info.insert(.canceled)
            }
            
            if let image {
                resultHandler(.success(image), info)
            } else {
                let error = infoDictionary?[PHImageErrorKey] as? NSError
                resultHandler(.failure(error ?? Failure.unknownError), info)
            }
        }
    }
    
    // TODO: Add something like "ForStorage" at the end to indicate that it's not for turning into an image?
    func getFullImageData(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let resource = PHAssetResource.assetResources(for: phAsset).first else {
            return completion(.failure(Failure.noResources))
        }
        var data: [Data] = []
        PHAssetResourceManager.default().requestData(for: resource, options: nil, dataReceivedHandler: { data.append($0) }) { error in
            guard !data.isEmpty else {
                return completion(.failure(error ?? Failure.unknownError))
            }
            return completion(.success(data.reduce(Data(), +)))
        }
    }
    
    // Maybe don't include this in the API, cuz it's probably better for
    // consumers to use getPreviewImage when displaying the image. The
    // only situation where this would be useful is if you could somehow
    // start the upload with limited data and then append more data as
    // it uploads, but I personally have no idea how that could be done
    //
    // Maybe make a silenceable warning with some kind of override function?
    func getFullImageDataProgressively(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let resource = PHAssetResource.assetResources(for: phAsset).first else {
            return completion(.failure(Failure.noResources))
        }
        var data = Data()
        PHAssetResourceManager.default().requestData(for: resource, options: nil) {
            data.append($0)
            completion(.success(data))
        } completionHandler: { error in
            if let error {
                completion(.failure(error))
            }
        }
    }
    
    enum Failure: Error {
        case noResources
        case unknownError
    }
    
    // MARK: Favorites
    
    var isFavorite: Bool {
        get {
            phAsset.isFavorite
        }
        set {
            editFavoriteState(isFavorite: newValue)
        }
    }
    
    func editFavoriteState(isFavorite: Bool, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard isFavorite != phAsset.isFavorite else { return completion?(.success(())) ?? () }
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest(for: phAsset).isFavorite = isFavorite
        } completionHandler: { success, error in
            if success {
                completion?(.success(()))
            } else {
                completion?(.failure(error ?? Failure.unknownError))
            }
        }
    }
    
    func favorite(completion: ((Result<Void, Error>) -> Void)? = nil) {
        editFavoriteState(isFavorite: true, completion: completion)
    }
    
    func unfavorite(completion: ((Result<Void, Error>) -> Void)? = nil) {
        editFavoriteState(isFavorite: false, completion: completion)
    }
    
    func editFavoriteState(isFavorite: Bool) async throws {
        guard isFavorite != phAsset.isFavorite else { return }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest(for: phAsset).isFavorite = isFavorite
        }
    }
    
    func favorite() async throws {
        try await editFavoriteState(isFavorite: true)
    }
    
    func unfavorite() async throws {
        try await editFavoriteState(isFavorite: false)
    }
}
