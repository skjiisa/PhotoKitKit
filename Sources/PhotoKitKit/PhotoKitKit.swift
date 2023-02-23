import SwiftUI
import Photos

#if os(macOS)
typealias UIImage = NSImage
#endif

// MARK: - AlbumController

class AlbumController: ObservableObject {
    @Published var collections: [PhotoCollection] = []
    
    func loadAllAlbums() {
        collections = PHAssetCollection
            .fetchTopLevelUserCollections(with: nil)
            .allObjects()
            .map(PhotoCollection.init)
    }
}

extension PhotoCollection {
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

// MARK: - PhotoCollection

enum PhotoCollection: PHFetchableWrapper {
    case album(Album)
    case folder(Folder)
    case unknown(PHCollection)
    
    var phCollection: PHCollection {
        switch self {
        case .album(let album):         return album.phAlbum
        case .folder(let folder):       return folder.phList
        case .unknown(let collection):  return collection
        }
    }
    
    // TODO: Make this return PHFetchResults<PhotoCollection> instead?
    var children: [PhotoCollection]? {
        guard case .folder(let folder) = self else {
            return nil
        }
        return folder.getCollections()
    }
    
    init(_ phCollection: PHCollection) {
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
    
    struct Album: PHFetchableWrapper {
        var phAlbum: PHAssetCollection
        
        init(_ phAlbum: PHAssetCollection) {
            self.phAlbum = phAlbum
        }
    }
    
    struct Folder {
        var phList: PHCollectionList
        
        init(_ phList: PHCollectionList) {
            self.phList = phList
        }
    }
}

extension PhotoCollection: Identifiable {
    var id: String {
        phCollection.id
    }
}

extension PhotoCollection.Album: Identifiable {
    var id: String {
        phAlbum.id
    }
}

extension PhotoCollection.Folder: Identifiable {
    var id: String {
        phList.id
    }
}

// MARK: Album + Convenience

extension PhotoCollection.Album {
    var title: String {
        phAlbum.localizedTitle ?? ""
    }
    
    func contains(_ asset: Asset) -> Bool {
        fetchAssets().fetchResults.contains(asset.phAsset)
    }
    
    func fetchAssets() -> PHFetchResults<Asset> {
        .init(PHAsset.fetchAssets(in: phAlbum, options: nil))
    }
}

// MARK: Folder + Convenience

extension PhotoCollection.Folder {
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

// MARK: - PHFetchResults

// PHAsset, PHCollection, PHAssetCollection, and PHCollectionList

protocol PHFetchable: AnyObject { }
extension PHAsset: PHFetchable { }
extension PHCollection: PHFetchable { }
// PHAssetCollection and PHCollectionList subclass PHCollection

protocol PHFetchableWrapper {
    associatedtype Wrapped: PHFetchable
    init(_: Wrapped)
}

struct PHFetchResults<Wrapper: PHFetchableWrapper>: Hashable {
    typealias FetchResults = PHFetchResult<Wrapper.Wrapped>
    var fetchResults: FetchResults
    
    init(_ fetchResults: FetchResults) {
        self.fetchResults = fetchResults
    }
}

extension PHFetchResults: RandomAccessCollection {
    var startIndex: Int {
        0
    }
    
    var endIndex: Int {
        fetchResults.count
    }
    
    func index(after i: Int) -> Int {
        i + 1
    }
    
    subscript(position: Int) -> Wrapper {
        // PHFetchResults is a class and I believe it has its own cache, so
        // I don't need to worry about caching stuff in AssetResults itself
        Wrapper(fetchResults.object(at: position))
    }
}

// MARK: - Asset

struct Asset: Hashable, PHFetchableWrapper {
    let phAsset: PHAsset
    
    init(_ phAsset: PHAsset) {
        self.phAsset = phAsset
    }
}

extension Asset: Identifiable {
    var id: String {
        phAsset.id
    }
}

extension Asset {
    //TODO: Options
    func getAllAlbumsLazily() -> PHFetchResults<PhotoCollection.Album> {
        .init(PHAssetCollection.fetchAssetCollectionsContaining(phAsset, with: .album, options: nil))
    }
    
    func getAllAlbums() -> [PhotoCollection.Album] {
        let fetchResults = PHAssetCollection.fetchAssetCollectionsContaining(phAsset, with: .album, options: nil)
        return fetchResults.objects(at: IndexSet(0..<fetchResults.count)).map(PhotoCollection.Album.init)
    }
    
    enum PreviewInfo: Hashable {
        case cloud
        case thumbnail
        case requestID(Int)
        case canceled
    }
    
    func getFullSizePreviewImage(
        contentMode: PHImageContentMode,
        options: PHImageRequestOptions? = nil,
        resultHandler: @escaping (Result<UIImage, Error>, Set<PreviewInfo>) -> Void
    ) {
        getPreviewImage(targetSize: PHImageManagerMaximumSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
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
