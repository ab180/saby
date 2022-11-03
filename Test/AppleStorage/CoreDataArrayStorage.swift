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
    
    fileprivate static let storage = CoreDataArrayStorage<CoredataTestItem>.create(
        objectPointer: CoreDataRawObjectPointer(bundle: Bundle.module, modelName: "Model"), entityName: "key"
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
        let expectation = self.expectation(description: "testGet")
        expectation.expectedFulfillmentCount = 1
        
        CoreDataArrayStorageTests.storage.then { storage in
            storage.context.performAndWait {
                let testItems = TestItemGroup(storage: storage).pushItems
                let targetItem = testItems[Int.random(in: 0 ... Int.max) % testItems.count]
                let uuid = targetItem.key
                
                testItems.forEach(storage.push)
                storage.nonPromiseSave()
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
                storage.nonPromiseSave()
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
                storage.nonPromiseSave()
                storage.get(limit: .unlimited)[0 ... testItems.removeCount - 1].forEach(storage.delete)
                storage.nonPromiseSave()
                let fetchedItems = storage.get(limit: .unlimited)
                XCTAssertEqual(fetchedItems.count, testItems.pushCount - testItems.removeCount)
            
                CoreDataArrayStorageTests.clear()
                expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
}
