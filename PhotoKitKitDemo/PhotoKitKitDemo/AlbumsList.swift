//
//  AlbumsList.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/8/23.
//

import SwiftUI
import Photos
import PhotoKitKit

// MARK: - Albums List

struct AlbumsList: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        List(viewModel.fetchResults, children: \.lazyChildren) { collection in
            switch collection {
            case .album(let album):
                NavigationLink(album.title) {
                    AlbumView(viewModel: viewModel.viewModel(for: album))
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
        private var albumViewModels = [PhotoCollection.Album: AlbumView.ViewModel]()
        
        override init() {
            self.fetchResults = PhotoCollection.fetchTopLevelCollections()
            super.init()
            
            registerPhotoObservation()
        }
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            process(change: changeInstance)
        }
        
        func viewModel(for album: PhotoCollection.Album) -> AlbumView.ViewModel {
            guard let viewModel = albumViewModels[album] else {
                let viewModel = AlbumView.ViewModel(album: album)
                albumViewModels[album] = viewModel
                return viewModel
            }
            return viewModel
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
