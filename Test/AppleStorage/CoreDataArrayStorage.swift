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

@objc (TestItem)
fileprivate class TestItem: CoreDataStorageDatable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TestItem> {
        NSFetchRequest<TestItem>(entityName: String(describing: self))
    }
    
    @NSManaged var key: UUID
    
    func updateData(_ mock: TestItem) {
        key = mock.key
    }
}

@objc (SecondTestItem)
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
            storage.save().then {
                CoreDataArrayStorageTests.clear()
                expectation.fulfill()
            }
        }.catch {
            XCTFail("make faild storage: \($0)")
        }
        
        CoreDataArrayStorageTests.storage2.then { storage in
            let item = SecondTestItem(context: storage.mockContext)
            item.key = UUID()
            storage.push(item)
            storage.save().then {
                expectation.fulfill()
            }
        }.catch {
            XCTFail("make faild storage: \($0)")
        }

        CoreDataArrayStorageTests.duplicateStorage.then { _ in
            expectation.fulfill()
        }.catch {
            XCTFail("make faild storage: \($0)")
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testGet() {
        let expectation = self.expectation(description: "testGet")
        expectation.expectedFulfillmentCount = 1
        
        CoreDataArrayStorageTests.storage.then { storage in
            let testItems = TestItemGroup(storage: storage).pushItems
            let targetItem = testItems[Int.random(in: 0 ... Int.max) % testItems.count]
            let uuid = targetItem.key
            
            testItems.forEach(storage.push)
            storage.save().then {
                storage.get(key: uuid).then { item in
                    XCTAssertNotNil(item)
                    expectation.fulfill()
                }
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testPush() {
        let expectation = self.expectation(description: "testPush")
        expectation.expectedFulfillmentCount = 2
        
        CoreDataArrayStorageTests.storage.then { storage in
            storage.get(limit: .unlimited).then { currentItems in
                
                let testItems = TestItemGroup(storage: storage)
                
                testItems.pushItems.forEach(storage.push)
                
                storage.get(limit: .unlimited).then {
                    XCTAssertEqual($0.count, testItems.pushCount + currentItems.count)
                    expectation.fulfill()
                    
                    storage.get(limit: .count(UInt.max)).then {
                        XCTAssertEqual($0.count, testItems.pushCount + currentItems.count)
                        
                        storage.save().then {
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testForStress() {
        let testCount = 100
        
        for index in 0 ... testCount {
            testGet()
            if index % 50 == 0 { print("get: \(index)") }
        }
        
        for index in 0 ... testCount {
            testPush()
            if index % 50 == 0 { print("push: \(index)") }
        }
        
        for index in 0 ... testCount {
            testRemove()
            if index % 50 == 0 { print("remove: \(index)") }
        }
    }
    
    func testRemove() {
        let expectation = self.expectation(description: "testRemove")
        expectation.expectedFulfillmentCount = 1
        
        CoreDataArrayStorageTests.storage.then { storage in
            storage.get(limit: .unlimited).then { existsItems in
                let testItems = TestItemGroup(storage: storage)
                
                testItems.pushItems.forEach(storage.push)
                storage.save().then {
                    
                    storage.get(limit: .unlimited).then {
                        $0[0 ... testItems.removeCount - 1].forEach(storage.delete)
                        storage.save().then {
                            
                            storage.get(limit: .unlimited).then { afterItems in
                                XCTAssertEqual(afterItems.count, existsItems.count + testItems.pushCount - testItems.removeCount)
                                expectation.fulfill()
                            }
                        }
                    }
                }
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
}
