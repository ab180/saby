//
//  FileValuePreferenceTest.swift
//  SabyApplePreferenceTest
//
//  Created by WOF on 2023/10/19.
//

import XCTest
import SabyConcurrency
@testable import SabyApplePreference

private struct DummyItem: Codable, Equatable {
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
        let fileURL = directoryURL.appendingPathComponent(storageName)
        
        if FileManager.default.fileExists(atPath: fileURL.absoluteString) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    func test__set() throws {
        try testObjects.forEach {
            try preference.set($0)
        }
        
        try preference.save()
        
        let value = try preference.get()
        XCTAssertNotEqual(value, nil)
    }
    
    func test__delete() throws {
        let testObjects = testObjects
        try testObjects.forEach {
            try preference.set($0)
        }

        try preference.save()
        try preference.clear()
        try preference.save()
        XCTAssertEqual(try preference.get(), nil)
    }
    
    func test__get() throws {
        let testCount = testCount
        let testObjects = testObjects
        let randomIndex = (0 ..< testCount).randomElement()!
        try testObjects.forEach {
            try preference.set($0)
        }
        
        try preference.set(testObjects[randomIndex])
        
        try preference.save()
        XCTAssertEqual(try preference.get(), testObjects[randomIndex])
    }
    
    func test__save() throws {
        let value = DummyItem(key: UUID())
        
        try preference.set(value)
        try preference.save()
        XCTAssertEqual(try preference.get(), value)
    }
}
