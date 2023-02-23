//
//  FileValueStorageTest.swift
//  SabyAppleStorageTest
//
//  Created by WOF on 2023/02/23.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

private let directoryName = "saby.dictionary.storage"

private struct DummyItem: Codable, Equatable {
    var key: UUID
}

final class FileValueStorageTest: XCTestCase {
    fileprivate static let testCount = 500
    fileprivate static let storage = FileValueStorage<DummyItem>(
        directoryName: directoryName,
        fileName: String(describing: DummyItem.self)
    )
    
    fileprivate var testObjects: [DummyItem] {
        var result: [DummyItem] = []
        for _ in 0 ..< FileValueStorageTest.testCount {
            result.append(DummyItem(key: UUID()))
        }
        
        return result
    }
    
    override class func setUp() {
        super.setUp()
        storage.delete()
    }
    
    class func clear() {
        storage.delete()
    }
    
    func test__set() throws {
        defer { FileValueStorageTest.clear() }
        
        let expectation = expectation(description: "test__set")
        expectation.expectedFulfillmentCount = 1
        
        testObjects.forEach {
            FileValueStorageTest.storage.set($0)
        }
        
        FileValueStorageTest.storage.save()
            .then { FileValueStorageTest.storage.get() }
            .then { XCTAssertNotEqual($0, nil) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__delete() throws {
        defer { FileValueStorageTest.clear() }
        
        let expectation = expectation(description: "test__delete")
        expectation.expectedFulfillmentCount = 1
        
        let testObjects = testObjects
        testObjects.forEach {
            FileValueStorageTest.storage.set($0)
        }

        FileValueStorageTest.storage.save()
            .then { FileValueStorageTest.storage.delete() }
            .then { FileValueStorageTest.storage.save() }
            .then { FileValueStorageTest.storage.get() }
            .then { XCTAssertEqual($0, nil) }
            .then { expectation.fulfill() }
            .catch { print($0) }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__get() throws {
        defer { FileValueStorageTest.clear() }
        
        let expectation = expectation(description: "test__get")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = FileValueStorageTest.testCount
        let testObjects = testObjects
        let randomIndex = (0 ..< testCount).randomElement()!
        testObjects.forEach {
            FileValueStorageTest.storage.set($0)
        }
        
        FileValueStorageTest.storage.set(testObjects[randomIndex])
        
        FileValueStorageTest.storage.save()
            .then { FileValueStorageTest.storage.get() }
            .then { XCTAssertEqual($0, testObjects[randomIndex]) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__save() throws {
        defer { FileValueStorageTest.clear() }
        
        let expectation = expectation(description: "test__save")
        expectation.expectedFulfillmentCount = 1
        
        let value = DummyItem(key: UUID())
        
        Promise { FileValueStorageTest.storage.set(value) }
            .then { FileValueStorageTest.storage.save() }
            .then { FileValueStorageTest.storage.get() }
            .then { XCTAssertEqual($0, value) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
}
