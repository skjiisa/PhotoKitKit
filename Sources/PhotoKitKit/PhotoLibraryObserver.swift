//
//  PhotoLibraryObserver.swift
//  PhotoKitKit
//
//  Created by Elaine Lyons on 2/22/23.
//

import Photos
import Combine
import SwiftUI

// MARK: PhotoLibrary

protocol PhotoLibrary {
    func register(_ observer: PHPhotoLibraryChangeObserver)
}

extension PHPhotoLibrary: PhotoLibrary { }

/// Injectable PhotoLibrary for the sake of unit testing the default
/// implementation of PhotoLibraryObserver.registerPhotoObservation().
///
/// I really don't like this solution, but this property is internal, so
/// it allows getting full unit test coverage without hurting the API.
var photoLibrary: PhotoLibrary = PHPhotoLibrary.shared()

// MARK: PhotoChange

public protocol PHPhotoChange {
    func changeDetails<T>(for fetchResult: PHFetchResult<T>) -> PHFetchResultChangeDetails<T>? where T : PHObject
}

extension PHChange: PHPhotoChange { }

// MARK: - PhotoLibraryObserver

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
        photoLibrary.register(self)
    }
    
    func process(change: PHPhotoChange) {
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
