//
//  PhotoLibraryObserver.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos
import Combine
import SwiftUI

public protocol PhotoLibraryObserver: PHPhotoLibraryChangeObserver, ObservableObject {
    associatedtype Result: PHFetchableWrapper
    // TODO: Should this be optional?
    // If it is, then a @StateObject can have it be nil
    // on initialization and have it set .onAppear.
    // Could also have two different protocols.
    var fetchResults: PHFetchResults<Result> { get set }
}

public extension PhotoLibraryObserver where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    func registerPhotoObservation() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func process(change: PHChange) {
        let oldResults = self.fetchResults.fetchResults
        guard let newResults = change
            .changeDetails(for: oldResults)?
            .fetchResultAfterChanges else { return }
        DispatchQueue.main.async {
            withAnimation {
                self.objectWillChange.send()
                self.fetchResults.fetchResults = newResults
            }
        }
    }
}
