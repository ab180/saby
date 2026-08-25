//
//  FileValueStorageTest.swift
//  SabyAppleStorageTest
//
//  Created by WOF on 2023/02/23.
//

import Foundation
import Testing
import SabyConcurrency
@testable import SabyAppleStorage

private struct DummyItem: Codable, Equatable, Sendable {
    var key: UUID
}

struct FileValueStorageTest {
    private let testCount = 500
    private let storage: FileValueStorage<DummyItem>
    private let directoryURL = FileManager.default.temporaryDirectory
    private let storageName: String
    
    fileprivate var testObjects: [DummyItem] {
        var result: [DummyItem] = []
        for _ in 0 ..< testCount {
            result.append(DummyItem(key: UUID()))
        }
        
        return result
    }
    
    init() {
        let storageName = UUID().uuidString
        self.storageName = storageName
        storage = FileValueStorage<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
    }
    
    @Test func set() async throws {
        for object in testObjects {
            try await storage.set(object).value()
        }
        
        try await storage.save().value()
        
        let value = try await storage.get().value()
        #expect(value != nil)
    }
    
    @Test func delete() async throws {
        let testObjects = testObjects
        for object in testObjects {
            try await storage.set(object).value()
        }

        try await storage.save().value()
        try await storage.clear().value()
        try await storage.save().value()
        #expect(try await storage.get().value() == nil)
    }
    
    @Test func get() async throws {
        let testCount = testCount
        let testObjects = testObjects
        let randomIndex = (0 ..< testCount).randomElement()!
        for object in testObjects {
            try await storage.set(object).value()
        }
        
        try await storage.set(testObjects[randomIndex]).value()
        
        try await storage.save().value()
        #expect(try await storage.get().value() == testObjects[randomIndex])
    }
    
    @Test func save() async throws {
        let value = DummyItem(key: UUID())

        try await storage.set(value).value()
        try await storage.save().value()
        #expect(try await storage.get().value() == value)
    }

    @Test func reload() async throws {
        let value = DummyItem(key: UUID())

        try await storage.set(value).value()
        try await storage.save().value()

        let reloaded = FileValueStorage<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
        #expect(try await reloaded.get().value() == value)
    }

    @Test func concurrent_set() async throws {
        let values = testObjects

        for promise in values.map(storage.set) {
            try await promise.value()
        }

        #expect(values.contains(try await storage.get().value()!))
    }
}
