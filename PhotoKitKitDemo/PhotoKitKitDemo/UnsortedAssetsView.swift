//
//  UnsortedAssetsView.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 4/25/23.
//

import SwiftUI
import PhotoKitKit

struct UnsortedAssetsView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var selection: Asset?
    
    var body: some View {
        ScrollView {
            if let assets = viewModel.assets {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    ForEach(assets) { staticAsset in
                        Button {
                            selection = Asset(staticAsset)
                        } label: {
                            Thumbnail(asset: staticAsset)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Unsorted")
        .sheet(item: $selection) { asset in
            AssetDetailsView(asset: asset)
        }
        .task {
            await viewModel.fetchAssets()
        }
    }
}

extension UnsortedAssetsView {
    @MainActor class ViewModel: ObservableObject {
        @Published var assets: [StaticAsset]?
        
        nonisolated func fetchAssetsSlow() async {
            let before = Date()
            
            let allAssets = StaticAsset.getAssets()
            let assets = allAssets.filter { asset in
                asset.fetchAllAlbums().underestimatedCount < 1
            }
            Task { @MainActor [assets] in
                self.assets = assets
            }
            
            let after = Date()
            let time = after.timeIntervalSince(before)
            print(time * 1000, "ms")
            print(assets.count)
        }
        
        nonisolated func fetchAssets() async {
            let before = Date()
            
            let sortedAssets = PhotoCollection.getAlbums().reduce(Set<StaticAsset>()) { partialResult, album in
                partialResult.union(album.getAssets())
            }
            
            let allAssets = StaticAsset.getAssets()
            let assets = allAssets.filter { !sortedAssets.contains($0) }
            
            Task { @MainActor [assets] in
                self.assets = assets
            }
            
            let after = Date()
            let time = after.timeIntervalSince(before)
            print(time * 1000, "ms")
            print(assets.count)
        }
    }
}

struct UnsortedAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        UnsortedAssetsView()
    }
}
