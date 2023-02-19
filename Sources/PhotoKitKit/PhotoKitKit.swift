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
            .compactMap(PhotoCollection.init)
    }
}

extension PhotoCollection {
    static func topLevelCollections() -> [PhotoCollection] {
        PHAssetCollection
            .fetchTopLevelUserCollections(with: nil)
            .allObjects()
            .compactMap(PhotoCollection.init)
    }
}

extension PHFetchResult {
    @objc func allObjects() -> [ObjectType] {
        objects(at: IndexSet(0..<count))
    }
}

// MARK: - PhotoCollection

enum PhotoCollection {
    case album(Album)
    case folder(Folder)
    
    var phCollection: PHCollection {
        switch self {
        case .album(let album):     return album.phAlbum
        case .folder(let folder):   return folder.phList
        }
    }
    
    var children: [PhotoCollection]? {
        guard case .folder(let folder) = self else {
            return nil
        }
        return folder.collections
    }
    
    init?(_ phCollection: PHCollection) {
        if let album = phCollection as? PHAssetCollection {
            self = .album(Album(album))
        } else if let folder = phCollection as? PHCollectionList {
            self = .folder(Folder(folder))
        } else {
            return nil
        }
    }
    
    struct Album: PHFetchableWrapper {
        var phAlbum: PHAssetCollection
        
        /// A lazy loading list of PHAssets in the album.
        /// This property conforms to RandomAccessCollection, so it can be accessed
        /// like an array, but it is important to note that it is performance heavy
        /// to load a large number of assets from, so it is not recommended to be
        /// used in something like an SwiftUI ForEach.
        var performanceHeavyAssetList: PHFetchResults<Asset>
        
        init(_ phAlbum: PHAssetCollection) {
            self.phAlbum = phAlbum
            let fetchResults = PHAsset.fetchAssets(in: phAlbum, options: nil)
            self.performanceHeavyAssetList = PHFetchResults<Asset>(fetchResults)
        }
    }
    
    struct Folder {
        var phList: PHCollectionList
        
        //let albumsList: PHFetchResults<Album>
        let collections: [PhotoCollection]
        
        init(_ phList: PHCollectionList) {
            self.phList = phList
            self.collections = PHCollection
                .fetchCollections(in: phList, options: nil)
                .allObjects()
                .compactMap(PhotoCollection.init)
        }
    }
}

extension PhotoCollection: Identifiable {
    var id: String {
        switch self {
        case .album(let album):     return album.id
        case .folder(let folder):   return folder.id
        }
    }
}

extension PhotoCollection.Album: Identifiable {
    var id: String {
        phAlbum.localIdentifier
    }
}

extension PhotoCollection.Folder: Identifiable {
    var id: String {
        phList.localIdentifier
    }
}

// MARK: Album + SwiftUI

extension PhotoCollection.Album {
    var title: String {
        phAlbum.localizedTitle ?? ""
    }
    
    func contains(_ asset: Asset) -> Bool {
        performanceHeavyAssetList.fetchResults.contains(asset.phAsset)
    }
    
    func list<C: View>(content: @escaping (Asset) -> C) -> some View {
        List(performanceHeavyAssetList, id: \.self) { asset in
            content(asset)
        }
    }
    
    func lazyVStack<C: View>(content: @escaping (Asset) -> C) -> some View {
        LazyVStack {
            ForEach(performanceHeavyAssetList, id: \.self) { asset in
                content(asset)
            }
        }
    }
    
    func lazyHStack<C: View>(content: @escaping (Asset) -> C) -> some View {
        LazyHStack {
            ForEach(performanceHeavyAssetList, id: \.self) { asset in
                content(asset)
            }
        }
    }
    
    func lazyVGrid<C: View>(
        columns: [GridItem],
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        pinnedViews: PinnedScrollableViews = .init(),
        content: @escaping (Asset) -> C
    ) -> some View {
        LazyVGrid(columns: columns, alignment: alignment, spacing: spacing, pinnedViews: pinnedViews) {
            ForEach(performanceHeavyAssetList, id: \.self) { asset in
                content(asset)
            }
        }
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
        phAsset.localIdentifier
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
