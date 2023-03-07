//
//  PHFetchResultsTests.swift
//  PhotoKitKitTests
//
//  Created by Elaine Lyons on 3/6/23.
//

import XCTest
import Photos
@testable import PhotoKitKit

final class PHFetchResultsTests: XCTestCase {
    
    // MARK: Typealiases
    
    private typealias SUT = PHFetchResults<Asset>
    private typealias FetchResult = MockAssetFetchResult
    
    // MARK: RandomAccessCollection

    func testStartIndex() {
        let sut = SUT(FetchResult())
        XCTAssertEqual(sut.startIndex, 0)
    }
    
    func testEndIndex() {
        let fetchResult = FetchResult()
        let sut = SUT(fetchResult)
        
        let expectedEndIndex = Int.random(in: 1...100)
        fetchResult._count = expectedEndIndex
        XCTAssertEqual(sut.endIndex, expectedEndIndex)
    }
    
    func testIndexAfter() {
        let sut = SUT(FetchResult())
        let inputIndex = Int.random(in: 1...100)
        let expectedIndex = inputIndex + 1
        XCTAssertEqual(sut.index(after: inputIndex), expectedIndex)
    }
    
    func testSubscript() {
        let fetchResult = FetchResult()
        let sut = SUT(fetchResult)
        
        let index = Int.random(in: 0...100)
        let expectedAsset = PHAsset()
        fetchResult._objectAtIndexReturn = expectedAsset
        
        XCTAssertIdentical(sut[index].phAsset, expectedAsset)
        XCTAssertEqual(fetchResult._objectAtIndex, index)
    }

}
