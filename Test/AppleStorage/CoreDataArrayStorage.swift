//
//  CoreDataArrayStorage.swift
//  
//
//  Created by MinJae on 9/28/22.
//

import XCTest
import Foundation
import SabyAppleStorage
import CoreData

@objc(CoredataTestItem)
fileprivate class CoredataTestItem: NSManagedObject, KeyIdentifiable, ManagedObjectUpdater {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CoredataTestItem> {
        NSFetchRequest<CoredataTestItem>(entityName: String(describing: self))
    }
    
    typealias Key = UUID
    @NSManaged var key: UUID
    
    func update(_ from: CoredataTestItem) {
        self.key = from.key
    }
}


final class CoreDataArrayStorageTests: XCTestCase {
    class func clear() {
        let storage = CoreDataArrayStorage<CoredataTestItem>(bundle: Bundle.module, modelNamed: "Model")
        try? storage?.removeAll()
    }
    
    override class func tearDown() {
        clear()
    }
    
    func testBasic() {
        defer { CoreDataArrayStorageTests.clear() }
        
        let storage = CoreDataArrayStorage<CoredataTestItem>(bundle: Bundle.module, modelNamed: "Model")
        XCTAssertNotNil(storage)
        guard let storage = storage else { return }
        
        let data = storage.get(limit: .unlimited)
        XCTAssertEqual(data.count, 0)
        
        let processingCount = 1000
        let removeCount = Int(processingCount / 10)
        
        var appendTargetItems: [CoredataTestItem] = []
        for _ in Range(0 ... processingCount - 1) {
            let item = CoredataTestItem(context: storage.mockContext)
            item.key = UUID()
            appendTargetItems.append(item)
        }
        
        // Append
        appendTargetItems.forEach(storage.push)
        try? storage.save()
        var fetchedItems = storage.get(limit: .unlimited)
        XCTAssertEqual(fetchedItems.count, processingCount)
        XCTAssertEqual(storage.get(limit: .count(UInt.max)).count, processingCount)
        
        // Delete
        fetchedItems[0 ... removeCount - 1].forEach(storage.delete)
        try? storage.save()
        fetchedItems = storage.get(limit: .unlimited)
        XCTAssertEqual(fetchedItems.count, processingCount - removeCount)
        
        // Rollback
        fetchedItems[0 ... removeCount - 1].forEach(storage.delete)
        storage.rollback()
        fetchedItems = storage.get(limit: .unlimited)
        XCTAssertEqual(fetchedItems.count, processingCount - removeCount)
        
        // Remove All
        try? storage.removeAll()
        fetchedItems = storage.get(limit: .unlimited)
        XCTAssertEqual(fetchedItems.count, 0)
    }
}
