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

@objc(TestItem)
fileprivate class TestItem: CoreDataStorageDatable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TestItem> {
        NSFetchRequest<TestItem>(entityName: String(describing: self))
    }
    
    @NSManaged var key: UUID
    
    func updateData(_ mock: TestItem) {
        key = mock.key
    }
}

@objc(SecondTestItem)
fileprivate class SecondTestItem: CoreDataStorageDatable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SecondTestItem> {
        NSFetchRequest<SecondTestItem>(entityName: String(describing: self))
    }
    
    @NSManaged var key: UUID
    
    func updateData(_ mock: SecondTestItem) {
        key = mock.key
    }
}

final class CoreDataArrayStorageTests: XCTestCase {
    
    fileprivate static let storage = CoreDataArrayStorage<TestItem>.create(
        objectPointer: CoreDataFetchPointer(bundle: Bundle.module, modelName: "Model"), entityKeyName: "key"
    )
    fileprivate static let storage2 = CoreDataArrayStorage<SecondTestItem>.create(
        objectPointer: CoreDataFetchPointer(bundle: Bundle.module, modelName: "Model"), entityKeyName: "key"
    )
    fileprivate static let duplicateStorage = CoreDataArrayStorage<SecondTestItem>.create(
        objectPointer: CoreDataFetchPointer(bundle: Bundle.module, modelName: "Model"), entityKeyName: "key"
    )
    
    class func clear() {
        storage.then({
            try? $0.removeAll()
        })
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
        
        var pushItems: [TestItem] = []
        var removeItems: [TestItem] = []
        init(storage: CoreDataArrayStorage<TestItem>) {
            for index in Range(0 ... pushCount - 1) {
                let item = TestItem(context: storage.mockContext)
                item.key = UUID()
                pushItems.append(item)
                if removeCount > index { removeItems.append(item) }
            }
        }
    }
    
    func testManagingMultipleEntity() {
        let expectation = self.expectation(description: "testManagingMultipleEntity")
        expectation.expectedFulfillmentCount = 3
        
        CoreDataArrayStorageTests.storage.then { storage in
            let item = TestItem(context: storage.mockContext)
            item.key = UUID()
            storage.push(item)
            try? storage.save()
            
            CoreDataArrayStorageTests.clear()
            expectation.fulfill()
        }
        
        CoreDataArrayStorageTests.storage2.then { storage in
            let item = SecondTestItem(context: storage.mockContext)
            item.key = UUID()
            storage.push(item)
            try? storage.save()
            expectation.fulfill()
        }
        
        CoreDataArrayStorageTests.duplicateStorage.then { _ in
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testGet() {
        let expectation = self.expectation(description: "testGet")
        expectation.expectedFulfillmentCount = 1
        
        CoreDataArrayStorageTests.storage.then { storage in
            storage.context.performAndWait {
                let testItems = TestItemGroup(storage: storage).pushItems
                let targetItem = testItems[Int.random(in: 0 ... Int.max) % testItems.count]
                let uuid = targetItem.key
                
                testItems.forEach(storage.push)
                try? storage.save()
                let item = storage.get(key: uuid)
                XCTAssertNotNil(item)
                
                CoreDataArrayStorageTests.clear()
                expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testPush() {
        let expectation = self.expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 1
        
        CoreDataArrayStorageTests.storage.then { storage in
            storage.context.performAndWait {
                let testItems = TestItemGroup(storage: storage)
                
                testItems.pushItems.forEach(storage.push)
                try? storage.save()
                
                XCTAssertEqual(storage.get(limit: .unlimited).count, testItems.pushCount)
                XCTAssertEqual(storage.get(limit: .count(UInt.max)).count, testItems.pushCount)
                
                CoreDataArrayStorageTests.clear()
                expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testForStress() {
        for _ in 0 ... 1000 {
            testRemove()
            CoreDataArrayStorageTests.clear()
        }
    }
    
    func testRemove() {
        let expectation = self.expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        CoreDataArrayStorageTests.storage.then { storage in
            storage.context.performAndWait {
                let testItems = TestItemGroup(storage: storage)
            
                testItems.pushItems.forEach(storage.push)
                try? storage.save()
                storage.get(limit: .unlimited)[0 ... testItems.removeCount - 1].forEach(storage.delete)
                try? storage.save()
                let fetchedItems = storage.get(limit: .unlimited)
                XCTAssertEqual(fetchedItems.count, testItems.pushCount - testItems.removeCount)
            
                CoreDataArrayStorageTests.clear()
                expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
}
