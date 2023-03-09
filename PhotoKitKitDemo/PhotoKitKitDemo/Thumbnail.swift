//
//  Thumbnail.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/8/23.
//

import SwiftUI
import Photos
import PhotoKitKit

// MARK: - Thumbnail

struct Thumbnail: View {
    @Environment(\.displayScale) private var displayScale
    
    var asset: Asset
    
    @State private var image: Result<UIImage, Error>?
    
    var body: some View {
        GeometryReader { geo in
            Group {
                switch image {
                case .success(let image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    Color.gray
                case .none:
                    ProgressView()
                        .fixedSize()
                        .onAppear {
                            let width = geo.size.width * displayScale
                            loadImage(size: CGSize(width: width, height: width))
                        }
                }
            }
            .frame(width: geo.size.width, height: geo.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
    }
    
    private func loadImage(size: CGSize) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        asset.getPreviewImage(targetSize: size, contentMode: .aspectFill, options: options) { result, _ in
            DispatchQueue.main.async {
                image = result
            }
        }
    }
}

// MARK: - Previews

struct Thumbnail_Previews: PreviewProvider {
    static var previews: some View {
        Thumbnail(asset: .init(.init()))
    }
}
