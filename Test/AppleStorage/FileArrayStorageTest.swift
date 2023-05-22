//
//  FileArrayStorageTests.swift
//  SabyAppleStorageTest
//
//  Created by MinJae on 9/27/22.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

fileprivate struct DummyItem: Codable {
    var key: UUID
}

private let directoryName = "saby.array.storage"

final class FileArrayStorageTest: XCTestCase {
    fileprivate var storage: FileArrayStorage<DummyItem>!
    
    private struct TestItemGroup {
        private static let testCount = 100
        
        let pushCount = TestItemGroup.testCount
        let removeCount = Int(TestItemGroup.testCount / 10)
        
        var pushItems: [DummyItem] = []
        var removeItems: [DummyItem] = []
        init() {
            for index in Range(0 ... pushCount - 1) {
                let item = DummyItem(key: UUID())
                pushItems.append(item)
                if removeCount > index { removeItems.append(item) }
            }
        }
    }
    
    override func setUpWithError() throws {
        let path = FileManager.default.urls(
            for: .libraryDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent(directoryName).path
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
        
        storage = FileArrayStorage<DummyItem>(
            directoryName: directoryName,
            fileName: String(describing: DummyItem.self)
        )
    }
    
    func test__duplicated_key() throws {
        let expectation = self.expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 1
        
        let sameUUID = UUID()
        let firstItem = DummyItem(key: sameUUID)
        let secondItem = DummyItem(key: sameUUID)
        
        _ = try storage.add(firstItem).wait()
        _ = try storage.add(secondItem).wait()
        
        Promise {
            self.storage.save()
        }.then {
            self.storage.get(limit: .unlimited)
        }.then { result in // Fetching Unlimit Count
            expectation.fulfill()
            return
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__push() throws {
        let expectation = self.expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 2
        
        let testItems = TestItemGroup()
        
        try testItems.pushItems.forEach { item in
            _ = try storage.add(item).wait()
        }
        
        Promise {
            self.storage.save()
        }.then {
            self.storage.get(limit: .unlimited)
        }.then { // Fetching Unlimit Count
            XCTAssertEqual($0.count, testItems.pushCount)
            expectation.fulfill()
            return
        }.then { // Fetching Max Count (Over)
            self.storage.get(limit: .count(Int.max))
        }.then {
            XCTAssertEqual($0.count, testItems.pushCount)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__remove() throws {
        let expectation = self.expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        let testItems = TestItemGroup()
        var testKeys = [UUID]()
        
        try testItems.pushItems.forEach { item in
            testKeys.append(try storage.add(item).wait())
        }
        Promise<Void, Error> {
            self.storage.save()
        }.then {
            self.storage.get(limit: .unlimited)
        }.then { _ in
            for index in 0 ..< testItems.removeCount {
                try self.storage.delete(key: testKeys[index]).wait()
            }
            return self.storage.save()
        }.then {
            self.storage.get(limit: .unlimited)
        }.then { fetchedItems in
            XCTAssertEqual(fetchedItems.count, testItems.pushCount - testItems.removeCount)
            expectation.fulfill()
        }.catch { error in
            XCTFail("failed Promise chaining: \(error)")
        }
        
        wait(for: [expectation], timeout: 5000)
    }
}
