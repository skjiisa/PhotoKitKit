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
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(viewModel.fetchResults) { asset in
                    Thumbnail(asset: asset)
                }
            }
        }
    }
}

// MARK: View Model

extension AlbumView {
    class ViewModel: NSObject, PhotoLibraryObserver {
        var fetchResults: PHFetchResults<Asset>
        
        init(album: PhotoCollection.Album) {
            self.fetchResults = album.fetchAssets()
        }
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            process(change: changeInstance)
        }
    }
}

// MARK: - Previews

struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView(viewModel: .init(album: .init(.init())))
    }
}
