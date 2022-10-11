//
//  CoreDataArrayStorage.swift
//  
//
//  Created by MinJae on 9/28/22.
//

import XCTest
import Foundation
import CoreData
@testable import SabyAppleStorage


@objc(CoredataTestItem)
fileprivate class CoredataTestItem: NSManagedObject, KeyIdentifiable, ManagedObjectUpdater {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CoredataTestItem> {
        NSFetchRequest<CoredataTestItem>(entityName: String(describing: self))
    }
    
    @NSManaged var key: UUID
    
    func updateData(_ mock: CoredataTestItem) {
        key = mock.key
    }
}


final class CoreDataArrayStorageTests: XCTestCase {
    
    fileprivate static let storage = CoreDataArrayStorage<CoredataTestItem>(bundle: Bundle.module, modelNamed: "Model", keyEntityNamed: "key")!
    
    class func clear() {
        try? storage.removeAll()
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
        
        var pushItems: [CoredataTestItem] = []
        var removeItems: [CoredataTestItem] = []
        init(storage: CoreDataArrayStorage<CoredataTestItem>) {
            for index in Range(0 ... pushCount - 1) {
                let item = CoredataTestItem(context: storage.mockContext)
                item.key = UUID()
                pushItems.append(item)
                if removeCount > index { removeItems.append(item) }
            }
        }
    }
    
    func testGet() {
        defer { CoreDataArrayStorageTests.clear() }
        
        let storage = CoreDataArrayStorageTests.storage
        let testItems = TestItemGroup(storage: storage).pushItems
        let targetItem = testItems[Int.random(in: 0 ... Int.max) % testItems.count]
        let uuid = targetItem.key
        
        let expectation = expectation(description: "testGet")
        expectation.expectedFulfillmentCount = 1
        
        testItems.forEach(storage.push)
        storage.save().then { _ in
            let item = storage.get(key: uuid)
            XCTAssertNotNil(item)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testPush() {
        defer { CoreDataArrayStorageTests.clear() }
        
        let storage = CoreDataArrayStorageTests.storage
        let testItems = TestItemGroup(storage: storage)
        
        let expectation = expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 1
        
        testItems.pushItems.forEach(storage.push)
        storage.save().then { _ in
            XCTAssertEqual(storage.get(limit: .unlimited).count, testItems.pushCount)
            XCTAssertEqual(storage.get(limit: .count(UInt.max)).count, testItems.pushCount)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRemove() {
        defer { CoreDataArrayStorageTests.clear() }
        
        let storage = CoreDataArrayStorageTests.storage
        let testItems = TestItemGroup(storage: storage)
        
        let expectation = expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        testItems.pushItems.forEach(storage.push)
        storage.save().then { _ in
            let fetchedItems = storage.get(limit: .unlimited)
            fetchedItems[0 ... testItems.removeCount - 1].forEach(storage.delete)
            
            storage.save().then { _ in
                let fetchedItems = storage.get(limit: .unlimited)
                XCTAssertEqual(fetchedItems.count, testItems.pushCount - testItems.removeCount)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
