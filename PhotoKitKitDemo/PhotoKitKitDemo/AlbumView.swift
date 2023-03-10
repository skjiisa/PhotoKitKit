//
//  AlbumView.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/8/23.
//

import SwiftUI
import Photos
import PhotoKitKit

// MARK: - AlbumView

struct AlbumView: View {
    
    @ObservedObject var albumDetails: AlbumDetails
    
    @State private var selection: Asset?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(albumDetails.fetchResults) { asset in
                    Button {
                        selection = asset
                    } label: {
                        Thumbnail(asset: asset)
                    }
                }
            }
        }
        .sheet(item: $selection) { asset in
            AssetDetailsView(asset: asset)
        }
    }
}

// MARK: View Model

class AlbumDetails: NSObject, PhotoLibraryObserver {
    var fetchResults: PHFetchResults<Asset>
    
    init(album: PhotoCollection.Album) {
        self.fetchResults = album.fetchAssets()
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        process(change: changeInstance)
    }
}

// MARK: - Previews

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(albumDetails: .init(album: .init(.init())))
    }
}
