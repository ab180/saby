//
//  FileDictionaryStorageTests.swift
//  SabyAppleStorageTest
//
//  Created by mjgu on 2023/01/19.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

fileprivate struct DummyItem: Codable, Equatable {
    var key: UUID
}

final class FileDictionaryStorageTest: XCTestCase {
    fileprivate let testCount = 500
    fileprivate var storage: FileDictionaryStorage<String, DummyItem>!
    fileprivate var directoryName: String!
    
    fileprivate var testObjects: [(String, DummyItem)] {
        var result: [(String, DummyItem)] = []
        for _ in 0 ..< testCount {
            result.append((UUID().uuidString, DummyItem(key: UUID())))
        }
        
        return result
    }
    
    override func setUpWithError() throws {
        directoryName = "saby.dictionary.storage.\(UUID())"
        storage = FileDictionaryStorage<String, DummyItem>(
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
    
    func test__insert() throws {
        let expectation = expectation(description: "testInsert")
        expectation.expectedFulfillmentCount = 1
        
        let testObjects = testObjects
        
        try testObjects.forEach {
            try storage.set(key: $0.0, value: $0.1).wait()
        }
        
        storage.save()
            .then {
                self.storage.contextPromise.capture { $0 }.then { $0.values.capture { print($0) } }
                try testObjects.forEach {
                    XCTAssertEqual(
                        try self.storage.get(key: $0.0).wait(),
                        $0.1
                    )
                }
            }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__delete() throws {
        let expectation = expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = testCount
        var testObjects = testObjects
        try testObjects.forEach {
            try storage.set(key: $0.0, value: $0.1).wait()
        }
        
        let removeCount = Int.random(in: 0 ..< (testCount / 2))
        let removeItems = testObjects[0 ..< removeCount]
        
        storage.save()
            .then {
                try testObjects.forEach {
                    XCTAssertEqual(
                        try self.storage.get(key: $0.0).wait(),
                        $0.1
                    )
                }
            }
            .then {
                try removeItems.forEach { try self.storage.delete(key: $0.0).wait() }
                removeItems.forEach { key, value in testObjects.removeAll { key == $0.0 } }
            }
            .then { self.storage.save() }
            .then {
                try testObjects.forEach {
                    XCTAssertEqual(
                        try self.storage.get(key: $0.0).wait(),
                        $0.1
                    )
                }
            }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__get() throws {
        let expectation = expectation(description: "testGet")
        expectation.expectedFulfillmentCount = 1
        
        let testCount = 50
        let randomIndex = (0 ..< testCount).randomElement()
        var targetKey: String = ""
        var targetValue: DummyItem?
        for index in 0 ..< testCount {
            let key = UUID().uuidString
            let value = DummyItem(key: UUID())
            try storage.set(key: key, value: value).wait()
            if randomIndex == index { targetKey = key; targetValue = value }
        }
        
        storage.save()
            .then { self.storage.get(key: targetKey) }
            .then { XCTAssertEqual($0?.key, targetValue?.key) }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test__save() throws {
        let expectation = expectation(description: "testSave")
        expectation.expectedFulfillmentCount = 1
        
        var entries = [(String, DummyItem)]()
        
        let setPromise: () -> Promise<Void, Error> = {
            Promise.async {
                let key = UUID().uuidString
                let value = DummyItem(key: UUID())
                entries.append((key, value))
                return self.storage.set(key: key, value: value)
            }
        }
        
        Promise
            .async { self.storage.save() }
            .then { setPromise() }
            .then { self.storage.save() }
            .then { setPromise() }
            .then { self.storage.save() }
            .then { setPromise() }
            .then { self.storage.save() }
            .then { setPromise() }
            .then {
                try entries.forEach {
                    XCTAssertEqual(
                        try self.storage.get(key: $0.0).wait(),
                        $0.1
                    )
                }
            }
            .then { expectation.fulfill() }
        
        wait(for: [expectation], timeout: 5)
    }
}
