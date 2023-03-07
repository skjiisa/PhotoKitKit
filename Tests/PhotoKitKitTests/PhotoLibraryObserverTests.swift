//
//  PhotoLibraryObserverTests.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 3/6/23.
//

import XCTest
import Photos
import Combine
@testable import PhotoKitKit

// MARK: TestablePhotoLibraryObserver

private final class TestablePhotoLibraryObserver: NSObject, PhotoLibraryObserver {
    var fetchResults = PHFetchResults<Asset>(.init())
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        process(change: changeInstance)
    }
}

// MARK: - PhotoLibraryObserverTests

final class PhotoLibraryObserverTests: XCTestCase {
    
    // MARK: Typealiases
    
    private typealias SUT = TestablePhotoLibraryObserver
    private typealias PhotoLibrary = MockPhotoLibrary
    private typealias Change = MockPHChange
    private typealias ChangeDetails = MockPHAssetFetchResultChangeDetails
    
    // MARK: Setup
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        subscriptions.removeAll()
    }

    override func tearDownWithError() throws {
        photoLibrary = PHPhotoLibrary.shared()
    }
    
    // MARK: Regristration

    func testRegistration() {
        let sut = SUT()
        let mockPhotoLibrary = PhotoLibrary()
        photoLibrary = mockPhotoLibrary
        
        sut.registerPhotoObservation()
        XCTAssertIdentical(mockPhotoLibrary._registerObserver, sut)
    }
    
    // MARK: Process change
    
    func testProcessChange() {
        let sut = SUT()
        let change = MockPHChange()
        let changeDetails = ChangeDetails()
        change._changes = changeDetails
        let expectedFetchResult = changeDetails._fetchResultAfterChanges
        
        let expectation = XCTestExpectation()
        sut.objectWillChange
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        XCTAssertNotIdentical(sut.fetchResults.fetchResults, expectedFetchResult)
        sut.process(change: change)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertIdentical(sut.fetchResults.fetchResults, expectedFetchResult)
    }
    
    func testProcessEmptyChange() {
        let sut = SUT()
        let change = MockPHChange()
        change._changes = nil
        let oldFetchResults = sut.fetchResults.fetchResults
        
        var changed = false
        sut.objectWillChange
            .sink { _ in
                changed = true
            }
            .store(in: &subscriptions)
        
        sut.process(change: change)
        
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
        XCTAssertIdentical(sut.fetchResults.fetchResults, oldFetchResults)
        XCTAssertFalse(changed)
    }

}
