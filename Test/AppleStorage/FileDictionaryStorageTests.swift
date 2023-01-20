//
//  FileDictionaryStorageTests.swift
//  
//
//  Created by mjgu on 2023/01/19.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

fileprivate struct DummyItem: Codable, KeyIdentifiable {
    typealias Key = UUID
    var key: UUID
}

final class FileDictionaryStorageTests: XCTestCase {
    fileprivate static let testCount = 500
    fileprivate static let storage = FileDictionaryStorage<String, DummyItem>(
        directoryName: "saby.storage",
        fileName: String(describing: DummyItem.self)
    )
    
    fileprivate var testObjects: [(String, DummyItem)] {
        var result: [(String, DummyItem)] = []
        for _ in 0 ..< FileDictionaryStorageTests.testCount {
            result.append((UUID().uuidString, DummyItem(key: UUID())))
        }
        
        return result
    }
    
    override class func setUp() {
        super.setUp()
        storage.removeAll()
    }
    
    class func clear() {
        storage.removeAll()
    }
    
    func testInsert() throws {
        defer { FileDictionaryStorageTests.clear() }
        
        let expectation = expectation(description: "testInsert")
        expectation.expectedFulfillmentCount = 1
        
        testObjects.forEach {
            FileDictionaryStorageTests.storage.set(key: $0.0, value: $0.1)
        }
        
        FileDictionaryStorageTests.storage.save()
            .then { XCTAssertEqual( FileDictionaryStorageTests.storage.keys.count, FileDictionaryStorageTests.testCount) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRemove() throws {
        defer { FileDictionaryStorageTests.clear() }
        
        let expectation = expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = FileDictionaryStorageTests.testCount
        let testObjects = testObjects
        testObjects.forEach {
            FileDictionaryStorageTests.storage.set(key: $0.0, value: $0.1)
        }
        
        let removeCount = Int.random(in: 0 ..< (testCount / 2))
        let removeItems = testObjects[0 ..< removeCount]
        
        let checkCount = testCount - removeCount
        FileDictionaryStorageTests.storage.save()
            .then { XCTAssertEqual( FileDictionaryStorageTests.storage.keys.count, testCount) }
            .then { XCTAssertEqual( FileDictionaryStorageTests.storage.values.count, testCount) }
            .then { removeItems.forEach { FileDictionaryStorageTests.storage.delete(key:$0.0) } }
            .then { FileDictionaryStorageTests.storage.save() }
            .then { XCTAssertEqual( FileDictionaryStorageTests.storage.keys.count, checkCount) }
            .then { XCTAssertEqual( FileDictionaryStorageTests.storage.keys.count, checkCount) }
            .then { XCTAssertEqual( FileDictionaryStorageTests.storage.values.count, checkCount) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testGet() throws {
        defer { FileDictionaryStorageTests.clear() }
        
        let expectation = expectation(description: "testGet")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = 50
        let randomIndex = (0 ..< testCount).randomElement()
        var targetKey: String = ""
        var targetValue: DummyItem?
        for index in 0 ..< testCount {
            let key = UUID().uuidString
            let value = DummyItem(key: UUID())
            FileDictionaryStorageTests.storage.set(key: key, value: value)
            if randomIndex == index { targetKey = key; targetValue = value }
        }
        
        FileDictionaryStorageTests.storage.save()
            .then { XCTAssertEqual( FileDictionaryStorageTests.storage.keys.count, testCount) }
            .then { FileDictionaryStorageTests.storage.get(key: targetKey) }
            .then { XCTAssertEqual($0.key, targetValue!.key) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
}
