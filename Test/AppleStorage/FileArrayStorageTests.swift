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
    
    private typealias ThenBlock = () -> ()
    private typealias EmptyWhenBlock = () -> ()
    private typealias WhenBlock = (BlockOperation) -> ()
    private func checker(_ manager: FileArrayStorage<DummyItem>, timer: TimeInterval = 10) -> (ThenBlock) -> () {
        executor(manager, timer: timer)({})
    }
    
    private func executor(_ manager: FileArrayStorage<DummyItem>, timer: TimeInterval = 10) -> (@escaping EmptyWhenBlock) -> (ThenBlock) -> () {
        return { when in return { then in
            self.executor(manager)({ _ in when() })(then)
        }}
    }
    
    private func executor(_ manager: FileArrayStorage<DummyItem>, timer: TimeInterval = 10) -> (@escaping WhenBlock) -> (ThenBlock) -> () {
        return { when in
            return { then in
                
                let expectationID = String(describing: UUID())
                let expectation = self.expectation(description: expectationID)
                expectation.expectedFulfillmentCount = 1

                let fulfillBlock = BlockOperation { expectation.fulfill() }
                
                when(fulfillBlock)
                manager.addOperation(fulfillBlock)
                XCTWaiter().wait(for: [expectation], timeout: timer)
                then()
            }
        }
    }
    
    private struct TestItemGroup {
        var appendItems: [DummyItem] = []
        var removeItems: [DummyItem] = []
        init(appendCount: Int, removeCount: Int) {
            for index in Range(0 ... appendCount - 1) {
                let item = DummyItem(key: UUID())
                appendItems.append(item)
                if removeCount > index { removeItems.append(item) }
            }
        }
    }
    
    private func makeTestItems(count: Int, removeCount: Int) -> (appendItems: [DummyItem], deleteItems: [DummyItem]) {
        var appendTargetItems: [DummyItem] = []
        var deleteTargetItems: [DummyItem] = []
        for index in Range(0 ... removeCount - 1) {
            let item = DummyItem(key: UUID())
            appendTargetItems.append(item)
            if removeCount > index { deleteTargetItems.append(item) }
        }
        
        return (appendTargetItems, deleteTargetItems)
    }
    
    func testBasic() {
        defer { FileArrayStorageTests.clear() }
        
        let storageManager: FileArrayStorage<DummyItem> = FileArrayStorage()
        
        let count = 100
        let removeCount = Int(count / 10)
        let testItemGroup = TestItemGroup(appendCount: count, removeCount: removeCount)
        
        // Push
        executor(storageManager)({
            testItemGroup.appendItems.forEach(storageManager.push)
        })({
            XCTAssertEqual(storageManager.get(limit: .unlimited).count, count)
            XCTAssertEqual(storageManager.get(limit: .count(UInt(removeCount))).count, removeCount)
        })
        
        // delete
        executor(storageManager)({
            testItemGroup.removeItems.forEach(storageManager.delete)
        })({
            let survivalCount = storageManager.get(limit: .unlimited).count
            XCTAssertEqual(survivalCount, count - removeCount)
            XCTAssertEqual(storageManager.get(limit: .count(UInt.max)).count, survivalCount)
        })
    }
    
    func testDeleteItemsOfEmptyStorarges() {
        defer { FileArrayStorageTests.clear() }
        
        let storageManager: FileArrayStorage<DummyItem> = FileArrayStorage()
        executor(storageManager)({
            XCTAssertEqual(storageManager.get(limit: .unlimited).count, 0)
            storageManager.delete(DummyItem(key: UUID()))
        })({
            XCTAssertEqual(storageManager.get(limit: .unlimited).count, 0)
        })
    }
    
    func testGetInEmptyStorages() {
        defer { FileArrayStorageTests.clear() }
        
        let storageManager: FileArrayStorage<DummyItem> = FileArrayStorage()
        checker(storageManager)({
            XCTAssertEqual(storageManager.get(limit: .count(UInt.max)).count, 0)
        })
        
        let key = UUID()
        executor(storageManager)({
            storageManager.push(DummyItem(key: key))
        })({
            XCTAssertNotNil(storageManager.get(key: key))
        })
    }
    
    func testAsyncInsertData() {
        defer { FileArrayStorageTests.clear() }
        
        let storageManager: FileArrayStorage<DummyItem> = FileArrayStorage()
        
        let count = 100
        let removeCount = Int(count / 10)
        let testItemGroup = TestItemGroup(appendCount: count, removeCount: removeCount)
        
        let insertGroupCount = 2
        
        let insert = { testItemGroup.appendItems.forEach(storageManager.push) }
        
        executor(storageManager)({
            for _ in Range(0 ... insertGroupCount) {
                insert()
            }
        })({
            XCTAssertEqual(storageManager.get(limit: .unlimited).count, ((insertGroupCount + 1) * 100))
        })
    }
}
