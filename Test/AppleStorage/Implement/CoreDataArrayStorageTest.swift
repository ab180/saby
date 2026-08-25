//
//  CoreDataArrayStorageTest.swift
//  SabyAppleStorageTest
//
//  Created by MinJae on 12/2/22.
//
//

import Testing
import CoreData
import SabyConcurrency
@testable import SabyAppleStorage

struct Value: Codable, KeyIdentifiable, Sendable {
    let key: UUID
}

struct CoreDataArrayStorageTest {
    let storage: CoreDataArrayStorage<Value>
    let encoder: JSONEncoder
    
    init() {
        storage = CoreDataArrayStorage(directoryURL: FileManager.default.temporaryDirectory, storageName: "\(UUID())")
        encoder = JSONEncoder()
    }
    
    @Test func managing_programically() async throws {
        let value = Value(key: UUID())
        let count = try await storage.get(limit: .unlimited).value().count
        try await storage.add(value).value()
        try await storage.save().value()
        #expect(try await storage.get(limit: .unlimited).value().count == count + 1)
    }
    
    @Test func length() async throws {
        let given = [
            Value(key: UUID()),
            Value(key: UUID()),
            Value(key: UUID())
        ]
        let expect = given.count
        
        for value in given {
            _ = try await self.storage.add(value).value()
        }
        let count = try await self.storage.count().value()
        
        #expect(count == expect)
    }
    
    @Test func size() async throws {
        let given = [
            Value(key: UUID()),
            Value(key: UUID()),
            Value(key: UUID())
        ]
        let expect = Double(given.reduce(0) { $0 + (try! encoder.encode($1).count) })
        
        for value in given {
            _ = try await self.storage.add(value).value()
        }
        let size = try await self.storage.size().value()
        
        #expect(size.byte == expect)
    }
    
    @Test func get_order_oldest() async throws {
        let givens = Array(repeating: 0, count: 100).map { _ in
            Value(key: UUID())
        }
        let expects = givens
        
        for value in givens {
            _ = try await storage.add(value).value()
        }
        let values = try await storage.get(limit: .unlimited, order: .oldest).value()
        
        for (value, expect) in zip(values, expects) {
            #expect(value.key == expect.key)
        }
    }
    
    @Test func get_order_newest() async throws {
        let givens = Array(repeating: 0, count: 100).map { _ in
            Value(key: UUID())
        }
        let expects = givens.reversed()
        
        for value in givens {
            _ = try await storage.add(value).value()
        }
        let values = try await storage.get(limit: .unlimited, order: .newest).value()
        
        for (value, expect) in zip(values, expects) {
            #expect(value.key == expect.key)
        }
    }

    @Test func reloads_existing_records() async throws {
        let storageName = "\(UUID())"
        let first = CoreDataArrayStorage<Value>(
            directoryURL: FileManager.default.temporaryDirectory,
            storageName: storageName
        )
        let given = [Value(key: UUID()), Value(key: UUID())]
        try await first.add(given).value()
        try await first.save().value()

        let reloaded = CoreDataArrayStorage<Value>(
            directoryURL: FileManager.default.temporaryDirectory,
            storageName: storageName
        )
        let result = try await reloaded.get(limit: .unlimited, order: .oldest).value()

        #expect(result.map(\.key) == given.map(\.key))
    }
}
