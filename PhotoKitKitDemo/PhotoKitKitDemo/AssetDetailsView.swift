//
//  AssetDetailsView.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/9/23.
//

import SwiftUI
import Photos
import PhotoKitKit

struct AssetDetailsView: View {
    
    var asset: Asset
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            // TODO: Create a custom view to handle this more elegantly?
            switch viewModel.image {
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            case .failure(_):
                Color.gray
            case .none:
                ProgressView()
                    .fixedSize()
                    .onAppear(perform: loadAsset)
            }
            
            if let albums = viewModel.fetchResults {
                Spacer()
                
                Text("Albums")
                    .font(.headline)
                ForEach(albums) { album in
                    Text(album.title)
                }
            }
            
            Spacer()
        }
    }
    
    private func loadAsset() {
        viewModel.loadPreviewImage(for: asset)
        viewModel.loadAlbums(for: asset)
    }
}

extension AssetDetailsView {
    class ViewModel: NSObject, PhotoLibraryObserverOptional {
        @Published var image: Result<UIImage, Error>?
        var fetchResults: PHFetchResults<PhotoCollection.Album>?
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            process(change: changeInstance)
        }
        
        func loadAlbums(for asset: Asset) {
            fetchResults = asset.fetchAllAlbums()
        }
        
        func loadPreviewImage(for asset: Asset) {
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            
            asset.getFullSizePreviewImage(options: options) { [weak self] result, _ in
                DispatchQueue.main.async {
                    self?.image = result
                }
            }
        }
    }
}

struct AssetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetDetailsView(asset: .init(.init()))
    }
}
