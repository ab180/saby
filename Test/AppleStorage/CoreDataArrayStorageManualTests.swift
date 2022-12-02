//
//  CoreDataArrayStorageManualTests.swift
//  
//
//  Created by MinJae on 12/2/22.
//

import XCTest
import CoreData
import SabyConcurrency
@testable import SabyAppleStorage

fileprivate class ManualyItem: CoreDataStorageDatable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManualyItem> {
        NSFetchRequest<ManualyItem>(entityName: String(describing: self))
    }
    
    @NSManaged var key: UUID
    
    func updateData(_ mock: ManualyItem) {
        key = mock.key
    }
}

class CoreDataArrayStorageManualTests: XCTestCase {
    
    func testManagingProgramically() {
        let entity = NSEntityDescription()
        entity.name = String(describing: ManualyItem.self)
        entity.managedObjectClassName = NSStringFromClass(ManualyItem.self)

        // Attributes
        let keyID = NSAttributeDescription()
        keyID.name = "key"
        keyID.attributeType = .UUIDAttributeType
        keyID.isOptional = true

        entity.properties = [keyID]
        
        let model = NSManagedObjectModel()
        model.entities = [entity]
        
        let storage = CoreDataArrayStorage<ManualyItem>.create(
            modelName: "ManualModel",
            managedObjectModel: model,
            entityKeyName: "key"
        )
        
        let expectation = self.expectation(description: "testManagingProgramically")
        expectation.expectedFulfillmentCount = 1
        
        storage.then { storage in
            let newItem = ManualyItem(context: storage.mockContext)
            newItem.key = UUID()
            
            var currentItem = 0
            Promise {
                storage.get(limit: .unlimited)
            }.then {
                currentItem = $0.count
                storage.push(newItem)
                return storage.save()
            }.then {
                storage.get(limit: .unlimited)
            }.then {
                XCTAssertEqual($0.count, currentItem + 1)
                expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
}
