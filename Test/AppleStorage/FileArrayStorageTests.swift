//
//  File.swift
//  
//
//  Created by MinJae on 9/27/22.
//

import XCTest
@testable import SabyAppleStorage

fileprivate struct DummyItem: Codable, KeyIdentifiable {
    typealias Key = UUID
    var key: UUID
}

final class FileArrayStorageTests: XCTestCase {
    
    fileprivate static let storage = FileArrayStorage<DummyItem>()
    
    class func clear() {
        storage.removeAll()
    }
    
    override class func setUp() {
        clear()
    }
    
    override class func tearDown() {
        clear()
    }
    
    private struct TestItemGroup {
        private static let testCount = 100
        
        let pushCount = TestItemGroup.testCount
        let removeCount = Int(TestItemGroup.testCount / 10)
        
        var pushItems: [DummyItem] = []
        var removeItems: [DummyItem] = []
        init() {
            for index in Range(0 ... pushCount - 1) {
                let item = DummyItem(key: UUID())
                pushItems.append(item)
                if removeCount > index { removeItems.append(item) }
            }
        }
    }
    
    func testPush() {
        defer { FileArrayStorageTests.clear() }
        
        let expectation = self.expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 2
        
        let storage = FileArrayStorageTests.storage
        let testItems = TestItemGroup()
        
        testItems.pushItems.forEach(storage.push)
        try? storage.save()
        
        storage.get(limit: .unlimited).then {
            XCTAssertEqual($0.count, testItems.pushCount)
            expectation.fulfill()
        }
        
        storage.get(limit: .count(UInt.max)).then {
            XCTAssertEqual($0.count, testItems.pushCount)
            expectation.fulfill()
        }
    }
    
    func testForStress() {
        for _ in 0 ... 1000 {
            testRemove()
            CoreDataArrayStorageTests.clear()
        }
    }
    
    func testRemove() {
        defer { FileArrayStorageTests.clear() }
        
        let expectation = self.expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        let storage = FileArrayStorageTests.storage
        let testItems = TestItemGroup()
        
        testItems.pushItems.forEach(storage.push)
        try? storage.save()
        storage.get(limit: .unlimited).then {
            $0[0 ... testItems.removeCount - 1].forEach(storage.delete)
            
            try? storage.save()
            storage.get(limit: .unlimited).then { fetchedItems in
                XCTAssertEqual(fetchedItems.count, testItems.pushCount - testItems.removeCount)
                expectation.fulfill()
            }
        }
    }
}
