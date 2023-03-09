//
//  ContentView.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/8/23.
//

import SwiftUI
import Photos

// MARK: - ContentView

struct ContentView: View {
    @State private var showLibrary = false
    
    var body: some View {
        NavigationView {
            if showLibrary {
                AlbumsList()
            } else {
                Text("Permission required")
            }
        }
        .task {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            showLibrary = [.authorized, .limited].contains(status)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
