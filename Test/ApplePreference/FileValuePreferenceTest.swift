//
//  FileValuePreferenceTest.swift
//  SabyApplePreferenceTest
//
//  Created by WOF on 2023/10/19.
//

import XCTest
@testable import SabyApplePreference

private struct DummyItem: Codable, Equatable, Sendable {
    var key: UUID
}

final class FileValuePreferenceTest: XCTestCase {
    fileprivate let testCount = 500
    fileprivate var preference: FileValuePreference<DummyItem>!
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
        preference = FileValuePreference<DummyItem>(
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
    
    func test__set() async throws {
        for object in testObjects {
            try await preference.set(object)
        }
        
        try await preference.save()
        
        let value = try await preference.get()
        XCTAssertNotEqual(value, nil)
    }
    
    func test__delete() async throws {
        let testObjects = testObjects
        for object in testObjects {
            try await preference.set(object)
        }

        try await preference.save()
        try await preference.clear()
        try await preference.save()
        let value = try await preference.get()
        XCTAssertNil(value)
    }
    
    func test__get() async throws {
        let testCount = testCount
        let testObjects = testObjects
        let randomIndex = (0 ..< testCount).randomElement()!
        for object in testObjects {
            try await preference.set(object)
        }
        
        try await preference.set(testObjects[randomIndex])
        
        try await preference.save()
        let value = try await preference.get()
        XCTAssertEqual(value, testObjects[randomIndex])
    }
    
    func test__save() async throws {
        let value = DummyItem(key: UUID())
        
        try await preference.set(value)
        try await preference.save()
        let storedValue = try await preference.get()
        XCTAssertEqual(storedValue, value)
    }

    func test__reload() async throws {
        let value = DummyItem(key: UUID())

        try await preference.set(value)
        try await preference.save()

        let reloaded = FileValuePreference<DummyItem>(
            directoryURL: directoryURL,
            storageName: storageName
        )
        let storedValue = try await reloaded.get()
        XCTAssertEqual(storedValue, value)
    }
}
