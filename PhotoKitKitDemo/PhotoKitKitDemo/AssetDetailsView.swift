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
    
    @ObservedObject var asset: Asset
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            // TODO: Create a custom view to handle this more elegantly?
            switch viewModel.image {
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(alignment: .topTrailing) {
                        favoriteButton
                    }
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
    
    private var favoriteButton: some View {
        Button {
            asset.toggleFavorite()
        } label: {
            let heart = asset.isFavorite ? "heart.fill" : "heart"
            Image(systemName: heart)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .foregroundColor(.red)
        }
        .padding()
    }
    
    private func loadAsset() {
        viewModel.loadPreviewImage(for: asset.staticAsset)
        viewModel.loadAlbums(for: asset.staticAsset)
    }
}

extension AssetDetailsView {
    class ViewModel: NSObject, PhotoLibraryObserverOptional {
        @Published var image: Result<UIImage, Error>?
        var fetchResults: PHFetchResults<PhotoCollection.Album>?
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            process(change: changeInstance)
        }
        
        func loadAlbums(for asset: StaticAsset) {
            fetchResults = asset.fetchAllAlbums()
        }
        
        func loadPreviewImage(for asset: StaticAsset) {
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
