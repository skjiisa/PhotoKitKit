//
//  StaticAsset.swift
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

public protocol AssetRepresentable {
    func fetchAllAlbums() -> PHFetchResults<PhotoCollection.Album>
}

// MARK: - StaticAsset

public struct StaticAsset: Hashable, PHFetchableWrapper {
    public let phAsset: PHAsset
    
    public init(_ phAsset: PHAsset) {
        self.phAsset = phAsset
    }
}

// MARK: - Identifiable

extension StaticAsset: Identifiable {
    public var id: String {
        phAsset.id
    }
}

// MARK: - Convenience

extension StaticAsset: AssetRepresentable {
    
    // MARK: Albums
    
    //TODO: Options
    // It seems like this doesn't actually update on its own from photo library change observations?
    public func fetchAllAlbums() -> PHFetchResults<PhotoCollection.Album> {
        .init(PHAssetCollection.fetchAssetCollectionsContaining(phAsset, with: .album, options: nil))
    }
    
    public func getAllAlbums() -> [PhotoCollection.Album] {
        PHAssetCollection
            .fetchAssetCollectionsContaining(phAsset, with: .album, options: nil)
            .allObjects()
            .map(PhotoCollection.Album.init)
    }
    
    // MARK: Image Data
    
    public enum PreviewInfo: Hashable {
        case cloud
        case thumbnail
        case requestID(Int)
        case canceled
    }
    
    public func getFullSizePreviewImage(
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<UIImage, Error>, Set<PreviewInfo>) -> Void
    ) {
        getPreviewImage(targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: resultHandler)
    }
    
    // TODO: Create async wrappers for these
    public func getPreviewImage(
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
    public func getFullImageData(completion: @escaping (Result<Data, Error>) -> Void) {
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
    public func getFullImageDataProgressively(completion: @escaping (Result<Data, Error>) -> Void) {
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
    
    public enum Failure: Error {
        case noResources
        case unknownError
    }
    
    public var isFavorite: Bool {
        phAsset.isFavorite
    }
}
