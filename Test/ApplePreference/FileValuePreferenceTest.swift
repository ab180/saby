//
//  FileValuePreferenceTest.swift
//  SabyApplePreferenceTest
//
//  Created by WOF on 2023/10/19.
//

import Foundation
import Testing
@testable import SabyApplePreference

private struct DummyItem: Codable, Equatable, Sendable {
    var key: UUID
}

struct FileValuePreferenceTest {
    private let testCount = 500
    private let preference: FileValuePreference<DummyItem>
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
        preference = FileValuePreference<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
    }
    
    @Test func set() async throws {
        for object in testObjects {
            try await preference.set(object)
        }
        
        try await preference.save()
        
        let value = try await preference.get()
        #expect(value != nil)
    }
    
    @Test func delete() async throws {
        let testObjects = testObjects
        for object in testObjects {
            try await preference.set(object)
        }

        try await preference.save()
        try await preference.clear()
        try await preference.save()
        let value = try await preference.get()
        #expect(value == nil)
    }
    
    @Test func get() async throws {
        let testCount = testCount
        let testObjects = testObjects
        let randomIndex = (0 ..< testCount).randomElement()!
        for object in testObjects {
            try await preference.set(object)
        }
        
        try await preference.set(testObjects[randomIndex])
        
        try await preference.save()
        let value = try await preference.get()
        #expect(value == testObjects[randomIndex])
    }
    
    @Test func save() async throws {
        let value = DummyItem(key: UUID())
        
        try await preference.set(value)
        try await preference.save()
        let storedValue = try await preference.get()
        #expect(storedValue == value)
    }

    @Test func reload() async throws {
        let value = DummyItem(key: UUID())

        try await preference.set(value)
        try await preference.save()

        let reloaded = FileValuePreference<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
        let storedValue = try await reloaded.get()
        #expect(storedValue == value)
    }
}
