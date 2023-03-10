//
//  AlbumsList.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/8/23.
//

import SwiftUI
import Photos
import PhotoKitKit
// Check out https://github.com/skjiisa/Coalescing-Operators
import CoalescingOperators

// MARK: - Albums List

struct AlbumsList: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        List(viewModel.fetchResults, children: \.lazyChildren) { collection in
            switch collection {
            case .album(let album):
                NavigationLink(album.title) {
                    AlbumView(albumDetails: viewModel.viewModel(for: album))
                }
            default:
                Text(collection.title)
            }
        }
        .navigationTitle("Albums")
    }
}

// MARK: View Model

extension AlbumsList {
    class ViewModel: NSObject, PhotoLibraryObserver {
        var fetchResults: PHFetchResults<PhotoCollection>
        private var albumViewModels = [PhotoCollection.Album: AlbumDetails]()
        
        override init() {
            self.fetchResults = PhotoCollection.fetchTopLevelCollections()
            super.init()
            
            registerPhotoObservation()
        }
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            process(change: changeInstance)
        }
        
        func viewModel(for album: PhotoCollection.Album) -> AlbumDetails {
            // ?= from CoalescingOperators
            albumViewModels[album] ?= AlbumDetails(album: album)
        }
    }
}

// MARK: - Previews

struct AlbumsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlbumsList()
        }
    }
}
