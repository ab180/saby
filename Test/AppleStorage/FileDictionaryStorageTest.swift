//
//  FileDictionaryStorageTests.swift
//  SabyAppleStorageTest
//
//  Created by mjgu on 2023/01/19.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

private let directoryName = "saby.dictionary.storage"

extension FileDictionaryStorage {
    func removeAll() {
        for key in self.keys { delete(key: key) }
    }
}

fileprivate struct DummyItem: Codable, KeyIdentifiable {
    typealias Key = UUID
    var key: UUID
}

final class FileDictionaryStorageTest: XCTestCase {
    fileprivate static let testCount = 500
    fileprivate static let storage = FileDictionaryStorage<String, DummyItem>(
        directoryName: directoryName,
        fileName: String(describing: DummyItem.self)
    )
    
    fileprivate var testObjects: [(String, DummyItem)] {
        var result: [(String, DummyItem)] = []
        for _ in 0 ..< FileDictionaryStorageTest.testCount {
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
        defer { FileDictionaryStorageTest.clear() }
        
        let expectation = expectation(description: "testInsert")
        expectation.expectedFulfillmentCount = 1
        
        testObjects.forEach {
            FileDictionaryStorageTest.storage.set(key: $0.0, value: $0.1)
        }
        
        FileDictionaryStorageTest.storage.save()
            .then { XCTAssertEqual( FileDictionaryStorageTest.storage.keys.count, FileDictionaryStorageTest.testCount) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRemove() throws {
        defer { FileDictionaryStorageTest.clear() }
        
        let expectation = expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = FileDictionaryStorageTest.testCount
        let testObjects = testObjects
        testObjects.forEach {
            FileDictionaryStorageTest.storage.set(key: $0.0, value: $0.1)
        }
        
        let removeCount = Int.random(in: 0 ..< (testCount / 2))
        let removeItems = testObjects[0 ..< removeCount]
        
        let checkCount = testCount - removeCount
        FileDictionaryStorageTest.storage.save()
            .then { XCTAssertEqual( FileDictionaryStorageTest.storage.keys.count, testCount) }
            .then { XCTAssertEqual( FileDictionaryStorageTest.storage.values.count, testCount) }
            .then { removeItems.forEach { FileDictionaryStorageTest.storage.delete(key:$0.0) } }
            .then { FileDictionaryStorageTest.storage.save() }
            .then { XCTAssertEqual( FileDictionaryStorageTest.storage.keys.count, checkCount) }
            .then { XCTAssertEqual( FileDictionaryStorageTest.storage.keys.count, checkCount) }
            .then { XCTAssertEqual( FileDictionaryStorageTest.storage.values.count, checkCount) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testGet() throws {
        defer { FileDictionaryStorageTest.clear() }
        
        let expectation = expectation(description: "testGet")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = 50
        let randomIndex = (0 ..< testCount).randomElement()
        var targetKey: String = ""
        var targetValue: DummyItem?
        for index in 0 ..< testCount {
            let key = UUID().uuidString
            let value = DummyItem(key: UUID())
            FileDictionaryStorageTest.storage.set(key: key, value: value)
            if randomIndex == index { targetKey = key; targetValue = value }
        }
        
        FileDictionaryStorageTest.storage.save()
            .then { XCTAssertEqual( FileDictionaryStorageTest.storage.keys.count, testCount) }
            .then { FileDictionaryStorageTest.storage.get(key: targetKey) }
            .then { XCTAssertEqual($0?.key, targetValue?.key) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testSave() throws {
        defer { FileDictionaryStorageTest.clear() }
        
        let expectation = expectation(description: "testSave")
        expectation.expectedFulfillmentCount = 1
        
        let setPromise: () -> Promise = {
            Promise {
                let key = UUID().uuidString
                let value = DummyItem(key: UUID())
                FileDictionaryStorageTest.storage.set(key: key, value: value)
            }
        }
        
        Promise.resolved(())
            .then { FileDictionaryStorageTest.storage.save() }
            .then { setPromise() }
            .then { FileDictionaryStorageTest.storage.save() }
            .then { setPromise() }
            .then { FileDictionaryStorageTest.storage.save() }
            .then { setPromise() }
            .then { FileDictionaryStorageTest.storage.save() }
            .then { setPromise() }
            .then { XCTAssertEqual(FileDictionaryStorageTest.storage.keys.count, 4)}
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
}
