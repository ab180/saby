//
//  FileArrayStorageTests.swift
//  SabyAppleStorageTest
//
//  Created by MinJae on 9/27/22.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

fileprivate struct DummyItem: Codable, KeyIdentifiable {
    let key: UUID
}

final class FileArrayStorageTest: XCTestCase {
    fileprivate var storage: FileArrayStorage<DummyItem>!
    fileprivate var encoder: JSONEncoder!
    fileprivate let directoryURL = FileManager.default.temporaryDirectory
    fileprivate var storageName: String!
    
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
        storageName = UUID().uuidString
        storage = FileArrayStorage<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
        encoder = JSONEncoder()
    }
    
    override func tearDownWithError() throws {
        let fileURL = directoryURL
        
        if FileManager.default.fileExists(atPath: fileURL.absoluteString) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func test__duplicated_key() throws {
        let expectation = self.expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 1
        
        let sameUUID = UUID()
        let firstItem = DummyItem(key: sameUUID)
        let secondItem = DummyItem(key: sameUUID)
        
        _ = try storage.add(firstItem).wait()
        _ = try storage.add(secondItem).wait()
        
        Promise.async {
            self.storage.save()
        }.then {
            self.storage.get(limit: .unlimited)
        }.then { result in // Fetching Unlimit Count
            expectation.fulfill()
            return
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test__push() throws {
        let expectation = self.expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 2
        
        let testItems = TestItemGroup()
        
        try testItems.pushItems.forEach { item in
            _ = try storage.add(item).wait()
        }
        
        Promise.async {
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
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test__remove() throws {
        let expectation = self.expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        let testItems = TestItemGroup()
        var testKeys = [UUID]()
        
        try testItems.pushItems.forEach { item in
            try storage.add(item).wait()
            testKeys.append(item.key)
        }
        Promise.async {
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
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test__length() throws {
        let given = [
            DummyItem(key: UUID()),
            DummyItem(key: UUID()),
            DummyItem(key: UUID())
        ]
        let expect = given.count
        
        for value in given {
            _ = try self.storage.add(value).wait()
        }
        let count = try self.storage.count().wait()
        
        XCTAssertEqual(count, expect)
    }
    
    func test__size() throws {
        let given = [
            DummyItem(key: UUID()),
            DummyItem(key: UUID()),
            DummyItem(key: UUID())
        ]
        let expect = Double(given.reduce(0) { $0 + (try! encoder.encode($1).count) })
        
        for value in given {
            print(try! encoder.encode(value).count)
            _ = try self.storage.add(value).wait()
        }
        let size = try self.storage.size().wait()
        
        XCTAssertEqual(size.byte, expect)
    }
    
    func test__get_order_oldest() throws {
        let givens = Array(repeating: 0, count: 100).map { _ in
            DummyItem(key: UUID())
        }
        let expects = givens
        
        for value in givens {
            _ = try storage.add(value).wait()
        }
        let values = try storage.get(limit: .unlimited, order: .oldest).wait()
        
        for (value, expect) in zip(values, expects) {
            XCTAssertEqual(value.key, expect.key)
        }
    }
    
    func test__get_order_newest() throws {
        let givens = Array(repeating: 0, count: 100).map { _ in
            DummyItem(key: UUID())
        }
        let expects = givens.reversed()
        
        for value in givens {
            _ = try storage.add(value).wait()
        }
        let values = try storage.get(limit: .unlimited, order: .newest).wait()
        
        for (value, expect) in zip(values, expects) {
            XCTAssertEqual(value.key, expect.key)
        }
    }
}
