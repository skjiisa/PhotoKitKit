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
        
        func fetchAssets() async {
            let assets = StaticAsset.getAssets()
            self.assets = assets.filter { asset in
                asset.fetchAllAlbums().underestimatedCount < 1
            }
        }
    }
}

struct UnsortedAssetsView_Previews: PreviewProvider {
    static var previews: some View {
        UnsortedAssetsView()
    }
}
