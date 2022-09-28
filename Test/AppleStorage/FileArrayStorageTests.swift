//
//  File.swift
//  
//
//  Created by MinJae on 9/27/22.
//

import XCTest
@testable import SabyAppleStorage

struct DummyItem: Codable, KeyIdentifiable {
    typealias Key = UUID
    var key: UUID
}

final class FileArrayStorageTests: XCTestCase {
    class func clear() {
        let manager = FileManager.default
        let urls = manager.urls(for: .libraryDirectory, in: .userDomainMask)
        guard false == urls.isEmpty else { return }
        
        let directoryName = "saby.storage"
        let result = urls[0].appendingPathComponent(directoryName)
        try? manager.removeItem(at: result)
    }
    
    override class func tearDown() {
        clear()
    }
    
    func testBasic() {
        defer { FileArrayStorageTests.clear() }
        
        let storageManager: FileArrayStorage<DummyItem> = FileArrayStorage()
        
        let processingCount = 100
        let removeCount = Int(processingCount / 10)
        
        // make items
        var appendTargetItems: [DummyItem] = []
        var deleteTargetItems: [DummyItem] = []
        for index in Range(0 ... processingCount - 1) {
            let item = DummyItem(key: UUID())
            appendTargetItems.append(item)
            if removeCount > index { deleteTargetItems.append(item) }
        }
        
        // push
        appendTargetItems.forEach(storageManager.push)
        XCTAssertEqual(storageManager.get(limit: .unlimited).count, processingCount)
        XCTAssertEqual(storageManager.get(limit: .count(UInt(removeCount))).count, removeCount)
        
        // delete
        deleteTargetItems.forEach(storageManager.delete)
        XCTAssertEqual(storageManager.get(limit: .unlimited).count, processingCount - removeCount)
    }
    
    func testDeleteInEmptyStorarges() {
        defer { FileArrayStorageTests.clear() }
        
        let storageManager: FileArrayStorage<DummyItem> = FileArrayStorage()
        
        XCTAssertEqual(storageManager.get(limit: .unlimited).count, 0)
        storageManager.delete(DummyItem(key: UUID()))
        XCTAssertEqual(storageManager.get(limit: .unlimited).count, 0)
    }
}
