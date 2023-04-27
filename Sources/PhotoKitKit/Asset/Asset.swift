//
//  Asset.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 3/10/23.
//

import Photos
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
public typealias UIImage = NSImage
#endif

public class Asset: NSObject, ObservableObject, AssetRepresentable {
    @Published public var phAsset: PHAsset
    
    public lazy var albums: PHFetchResults<PhotoCollection.Album> = {
        albumsLoaded = true
        return staticAsset.fetchAllAlbums()
    }()
    private var albumsLoaded = false
    
    public var changeAnimation: Animation? = .default
    
    public required init(_ phAsset: PHAsset) {
        self.phAsset = phAsset.reload()
        super.init()
        photoLibrary.register(self)
    }
    
    public convenience init(_ staticAsset: StaticAsset) {
        self.init(staticAsset.phAsset)
    }
}

extension Asset {
    public var staticAsset: StaticAsset {
        StaticAsset(phAsset)
    }
}

// MARK: - Convenience

extension Asset {
    
    // MARK: Albums
    
    public func fetchAllAlbums() -> PHFetchResults<PhotoCollection.Album> {
        staticAsset.fetchAllAlbums()
    }
    
    public func getAllAlbums() -> [PhotoCollection.Album] {
        staticAsset.getAllAlbums()
    }
    
    // MARK: Image Data
    
    public typealias PreviewInfo = StaticAsset.PreviewInfo
    
    public func getFullSizePreviewImage(
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<UIImage, Failure>, Set<PreviewInfo>) -> Void
    ) {
        staticAsset.getFullSizePreviewImage(options: options, resultHandler: resultHandler)
    }
    
    public func getPreviewImage(
        targetSize: CGSize,
        contentMode: PHImageContentMode,
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<UIImage, Failure>, Set<PreviewInfo>) -> Void
    ) {
        staticAsset.getPreviewImage(targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
    public func getFullImageData(completion: @escaping (Result<Data, Failure>) -> Void) {
        staticAsset.getFullImageData(completion: completion)
    }
    
    public func getFullImageDataProgressively(completion: @escaping (Result<Data, Failure>) -> Void) {
        staticAsset.getFullImageDataProgressively(completion: completion)
    }
    
    // MARK: Favorites
    
    public typealias Failure = StaticAsset.Failure
    
    public enum ChangeResult {
        case success
        case failure(Failure)
    }
    
    public func editFavoriteState(isFavorite: Bool, completion: ((ChangeResult) -> Void)? = nil) {
        // Don't make a change request when there's nothing to change
        guard isFavorite != phAsset.isFavorite else {
            return completion?(.success) ?? ()
        }
        
        let phAsset = self.phAsset
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest(for: phAsset).isFavorite = isFavorite
        } completionHandler: { success, error in
            switch (success, error) {
            case (true, _):
                completion?(.success)
            case (false, .some(let error)):
                completion?(.failure(.photoKit(error)))
            case (false, .none):
                completion?(.failure(.unknownError))
            }
        }
    }
    
    public func favorite(completion: ((ChangeResult) -> Void)? = nil) {
        editFavoriteState(isFavorite: true, completion: completion)
    }
    
    public func unfavorite(completion: ((ChangeResult) -> Void)? = nil) {
        editFavoriteState(isFavorite: false, completion: completion)
    }
    
    public func toggleFavorite(completion: ((ChangeResult) -> Void)? = nil) {
        editFavoriteState(isFavorite: !isFavorite, completion: completion)
    }
    
    public func editFavoriteState(isFavorite: Bool) async throws {
        guard isFavorite != phAsset.isFavorite else { return }
        
        let phAsset = self.phAsset
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest(for: phAsset).isFavorite = isFavorite
        }
    }
    
    public func favorite() async throws {
        try await editFavoriteState(isFavorite: true)
    }
    
    public func unfavorite() async throws {
        try await editFavoriteState(isFavorite: false)
    }
    
    public func toggleFavorite() async throws {
        try await editFavoriteState(isFavorite: !isFavorite)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension Asset: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        processAsset(change: changeInstance)
        processAlbums(change: changeInstance)
    }
    
    private func processAsset(change: PHChange) {
        guard let newAsset = change
            .changeDetails(for: phAsset)?
            .objectAfterChanges else { return }
        
        print("Asset processing:", id)
        self.animate {
            self.phAsset = newAsset
        }
    }
    
    private func processAlbums(change: PHChange) {
        guard
            albumsLoaded,
            let newFetchResults = change
                .changeDetails(for: albums.fetchResults)?
                .fetchResultAfterChanges
        else { return }
        
        print("Asset albums processing:", id)
        self.animate {
            self.albums.fetchResults = newFetchResults
        }
    }
    
    private func animate(change: @escaping () -> Void) {
        Task { @MainActor in
            withAnimation(changeAnimation) {
                self.objectWillChange.send()
                change()
            }
        }
    }
}
