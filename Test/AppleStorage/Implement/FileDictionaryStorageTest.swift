//
//  FileDictionaryStorageTests.swift
//  SabyAppleStorageTest
//
//  Created by mjgu on 2023/01/19.
//

import XCTest
import SabyConcurrency
@testable import SabyAppleStorage

fileprivate struct DummyItem: Codable, Equatable, Sendable {
    var key: UUID
}

final class FileDictionaryStorageTest: XCTestCase {
    fileprivate let testCount = 500
    fileprivate var storage: FileDictionaryStorage<String, DummyItem>!
    fileprivate let directoryURL = FileManager.default.temporaryDirectory
    fileprivate var storageName: String!
    
    fileprivate var testObjects: [(String, DummyItem)] {
        var result: [(String, DummyItem)] = []
        for _ in 0 ..< testCount {
            result.append((UUID().uuidString, DummyItem(key: UUID())))
        }
        
        return result
    }
    
    override func setUpWithError() throws {
        storageName = UUID().uuidString
        storage = FileDictionaryStorage<String, DummyItem>(
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
    
    func test__insert() throws {
        let testObjects = testObjects
        
        try testObjects.forEach {
            try storage.set(key: $0.0, value: $0.1).wait()
        }
        
        try storage.save().wait()
        try testObjects.forEach {
            XCTAssertEqual(try storage.get(key: $0.0).wait(), $0.1)
        }
    }
    
    func test__delete() throws {
        let testCount = testCount
        var testObjects = testObjects
        try testObjects.forEach {
            try storage.set(key: $0.0, value: $0.1).wait()
        }
        
        let removeCount = Int.random(in: 0 ..< (testCount / 2))
        let removeItems = testObjects[0 ..< removeCount]
        
        try storage.save().wait()
        try testObjects.forEach {
            XCTAssertEqual(try storage.get(key: $0.0).wait(), $0.1)
        }
        try removeItems.forEach { try storage.delete(key: $0.0).wait() }
        removeItems.forEach { key, _ in testObjects.removeAll { key == $0.0 } }
        try storage.save().wait()
        try testObjects.forEach {
            XCTAssertEqual(try storage.get(key: $0.0).wait(), $0.1)
        }
    }
    
    func test__get() throws {
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
        
        try storage.save().wait()
        XCTAssertEqual(try storage.get(key: targetKey).wait()?.key, targetValue?.key)
    }
    
    func test__save() throws {
        var entries = [(String, DummyItem)]()

        try storage.save().wait()
        for _ in 0 ..< 4 {
            let key = UUID().uuidString
            let value = DummyItem(key: UUID())
            entries.append((key, value))
            try storage.set(key: key, value: value).wait()
            try storage.save().wait()
        }
        try entries.forEach {
            XCTAssertEqual(try storage.get(key: $0.0).wait(), $0.1)
        }
    }
}
