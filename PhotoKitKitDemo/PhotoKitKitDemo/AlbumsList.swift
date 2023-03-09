//
//  AlbumsList.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/8/23.
//

import SwiftUI
import Photos
import PhotoKitKit

struct AlbumsList: View {
    @StateObject private var albums = ViewModel()
    
    var body: some View {
        List(albums.fetchResults, children: \.lazyChildren) { album in
            Text(album.title)
        }
        .navigationTitle("Albums")
    }
}

extension AlbumsList {
    class ViewModel: NSObject, PhotoLibraryObserver {
        var fetchResults: PHFetchResults<PhotoCollection>
        
        override init() {
            self.fetchResults = PhotoCollection.fetchTopLevelCollections()
            super.init()
            
            registerPhotoObservation()
        }
        
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            process(change: changeInstance)
        }
    }
}

struct AlbumsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlbumsList()
        }
    }
}
