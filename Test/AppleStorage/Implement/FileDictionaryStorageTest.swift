//
//  FileDictionaryStorageTests.swift
//  SabyAppleStorageTest
//
//  Created by mjgu on 2023/01/19.
//

import Foundation
import Testing
import SabyConcurrency
@testable import SabyAppleStorage

fileprivate struct DummyItem: Codable, Equatable, Sendable {
    var key: UUID
}

struct FileDictionaryStorageTest {
    private let testCount = 500
    private let storage: FileDictionaryStorage<String, DummyItem>
    private let directoryURL = FileManager.default.temporaryDirectory
    private let storageName: String
    
    fileprivate var testObjects: [(String, DummyItem)] {
        var result: [(String, DummyItem)] = []
        for _ in 0 ..< testCount {
            result.append((UUID().uuidString, DummyItem(key: UUID())))
        }
        
        return result
    }
    
    init() {
        let storageName = UUID().uuidString
        self.storageName = storageName
        storage = FileDictionaryStorage<String, DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
    }
    
    @Test func insert() async throws {
        let testObjects = testObjects
        
        for entry in testObjects {
            try await storage.set(key: entry.0, value: entry.1).value()
        }
        
        try await storage.save().value()
        for entry in testObjects {
            #expect(try await storage.get(key: entry.0).value() == entry.1)
        }
    }
    
    @Test func delete() async throws {
        let testCount = testCount
        var testObjects = testObjects
        for entry in testObjects {
            try await storage.set(key: entry.0, value: entry.1).value()
        }
        
        let removeCount = Int.random(in: 0 ..< (testCount / 2))
        let removeItems = testObjects[0 ..< removeCount]
        
        try await storage.save().value()
        for entry in testObjects {
            #expect(try await storage.get(key: entry.0).value() == entry.1)
        }
        for entry in removeItems {
            try await storage.delete(key: entry.0).value()
        }
        removeItems.forEach { key, _ in testObjects.removeAll { key == $0.0 } }
        try await storage.save().value()
        for entry in testObjects {
            #expect(try await storage.get(key: entry.0).value() == entry.1)
        }
    }
    
    @Test func get() async throws {
        let testCount = 50
        let randomIndex = (0 ..< testCount).randomElement()
        var targetKey: String = ""
        var targetValue: DummyItem?
        for index in 0 ..< testCount {
            let key = UUID().uuidString
            let value = DummyItem(key: UUID())
            try await storage.set(key: key, value: value).value()
            if randomIndex == index { targetKey = key; targetValue = value }
        }
        
        try await storage.save().value()
        #expect(try await storage.get(key: targetKey).value()?.key == targetValue?.key)
    }
    
    @Test func save() async throws {
        var entries = [(String, DummyItem)]()

        try await storage.save().value()
        for _ in 0 ..< 4 {
            let key = UUID().uuidString
            let value = DummyItem(key: UUID())
            entries.append((key, value))
            try await storage.set(key: key, value: value).value()
            try await storage.save().value()
        }
        for entry in entries {
            #expect(try await storage.get(key: entry.0).value() == entry.1)
        }
    }

    @Test func concurrent_set() async throws {
        let entries = testObjects
        let promises = entries.map { storage.set(key: $0.0, value: $0.1) }

        for promise in promises {
            try await promise.value()
        }

        #expect(try await storage.get(limit: .unlimited).value().count == entries.count)
    }

    @Test func reload() async throws {
        let key = UUID().uuidString
        let value = DummyItem(key: UUID())
        try await storage.set(key: key, value: value).value()
        try await storage.save().value()

        let reloaded = FileDictionaryStorage<String, DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )

        #expect(try await reloaded.get(key: key).value() == value)
    }
}
