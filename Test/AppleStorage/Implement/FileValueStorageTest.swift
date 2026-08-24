//
//  FileValueStorageTest.swift
//  SabyAppleStorageTest
//
//  Created by WOF on 2023/02/23.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

private struct DummyItem: Codable, Equatable, Sendable {
    var key: UUID
}

final class FileValueStorageTest: XCTestCase {
    fileprivate let testCount = 500
    fileprivate var storage: FileValueStorage<DummyItem>!
    fileprivate let directoryURL = FileManager.default.temporaryDirectory
    fileprivate var storageName: String!
    
    fileprivate var testObjects: [DummyItem] {
        var result: [DummyItem] = []
        for _ in 0 ..< testCount {
            result.append(DummyItem(key: UUID()))
        }
        
        return result
    }
    
    override func setUpWithError() throws {
        storageName = UUID().uuidString
        storage = FileValueStorage<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
    }
    
    override func tearDownWithError() throws {
        let fileURL = directoryURL
        
        if FileManager.default.fileExists(atPath: fileURL.absoluteString) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func test__set() throws {
        try testObjects.forEach {
            try storage.set($0).wait()
        }
        
        try storage.save().wait()
        
        let value = try storage.get().wait()
        XCTAssertNotEqual(value, nil)
    }
    
    func test__delete() throws {
        let testObjects = testObjects
        try testObjects.forEach {
            try storage.set($0).wait()
        }

        try storage.save().wait()
        try storage.clear().wait()
        try storage.save().wait()
        XCTAssertNil(try storage.get().wait())
    }
    
    func test__get() throws {
        let testCount = testCount
        let testObjects = testObjects
        let randomIndex = (0 ..< testCount).randomElement()!
        try testObjects.forEach {
            try storage.set($0).wait()
        }
        
        try storage.set(testObjects[randomIndex]).wait()
        
        try storage.save().wait()
        XCTAssertEqual(try storage.get().wait(), testObjects[randomIndex])
    }
    
    func test__save() throws {
        let value = DummyItem(key: UUID())

        try storage.set(value).wait()
        try storage.save().wait()
        XCTAssertEqual(try storage.get().wait(), value)
    }

    func test__reload() throws {
        let value = DummyItem(key: UUID())

        try storage.set(value).wait()
        try storage.save().wait()

        let reloaded = FileValueStorage<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
        XCTAssertEqual(try reloaded.get().wait(), value)
    }

    func test__concurrent_set() throws {
        let values = testObjects

        try values
            .map(storage.set)
            .forEach { try $0.wait() }

        XCTAssertTrue(values.contains(try storage.get().wait()!))
    }
}
