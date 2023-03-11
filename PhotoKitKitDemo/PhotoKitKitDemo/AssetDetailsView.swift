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
    
    @State private var image: Result<UIImage, Error>?
    
    var body: some View {
        VStack {
            switch image {
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
                    .onAppear(perform: loadImage)
            }
            
            Spacer()
            
            Text("Albums")
                .font(.headline)
            ForEach(asset.albums) { album in
                Text(album.title)
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
    
    private func loadImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        asset.getFullSizePreviewImage(options: options) { result, _ in
            DispatchQueue.main.async {
                self.image = result
            }
        }
    }
}

struct AssetDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        AssetDetailsView(asset: .init(.init()))
    }
}
