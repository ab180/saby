//
//  FileValueStorageTest.swift
//  SabyAppleStorageTest
//
//  Created by WOF on 2023/02/23.
//

import XCTest
import SabyConcurrency
import SabyTestExtension
@testable import SabyAppleStorage

private struct DummyItem: Codable, Equatable {
    var key: UUID
}

final class FileValueStorageTest: XCTestCase {
    fileprivate let testCount = 500
    fileprivate var storage: FileValueStorage<DummyItem>!
    fileprivate var directoryName: String!
    
    fileprivate var testObjects: [DummyItem] {
        var result: [DummyItem] = []
        for _ in 0 ..< testCount {
            result.append(DummyItem(key: UUID()))
        }
        
        return result
    }
    
    override func setUpWithError() throws {
        directoryName = "saby.dictionary.value.storage.\(UUID())"
        storage = FileValueStorage<DummyItem>(
            directoryName: directoryName,
            fileName: String(describing: DummyItem.self)
        )
    }
    
    override func tearDownWithError() throws {
        let path = FileManager.default.urls(
            for: .libraryDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent(directoryName).path
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    }
    
    func test__set() throws {
        let expectation = expectation(description: "test__set")
        expectation.expectedFulfillmentCount = 1
        
        try testObjects.forEach {
            try storage.set($0).wait()
        }
        
        storage.save()
            .then { self.storage.get() }
            .then { XCTAssertNotEqual($0, nil) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__delete() throws {
        let expectation = expectation(description: "test__delete")
        expectation.expectedFulfillmentCount = 1
        
        let testObjects = testObjects
        try testObjects.forEach {
            try storage.set($0).wait()
        }

        storage.save()
            .then { self.storage.clear() }
            .then { self.storage.save() }
            .then { self.storage.get() }
            .then { XCTAssertEqual($0, nil) }
            .then { expectation.fulfill() }
            .catch { print($0) }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__get() throws {
        let expectation = expectation(description: "test__get")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = testCount
        let testObjects = testObjects
        let randomIndex = (0 ..< testCount).randomElement()!
        try testObjects.forEach {
            try storage.set($0).wait()
        }
        
        try storage.set(testObjects[randomIndex]).wait()
        
        storage.save()
            .then { self.storage.get() }
            .then { XCTAssertEqual($0, testObjects[randomIndex]) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__save() throws {
        let expectation = expectation(description: "test__save")
        expectation.expectedFulfillmentCount = 1
        
        let value = DummyItem(key: UUID())
        
        Promise.async { self.storage.set(value) }
            .then { self.storage.save() }
            .then { self.storage.get() }
            .then { XCTAssertEqual($0, value) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
}
