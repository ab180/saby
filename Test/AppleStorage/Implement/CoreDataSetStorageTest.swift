//
//  CoreDataSetStorageTest.swift
//  SabyAppleStorageTest
//

import CoreData
import XCTest
@testable import SabyAppleStorage

private struct SetValue: Codable, Hashable {
    let id: Int
}

private struct LegacySetValue: Codable, Hashable {
    let first: Int
    let second: Int
}

final class CoreDataSetStorageTest: XCTestCase {
    private var storage: CoreDataSetStorage<SetValue>!

    override func setUpWithError() throws {
        storage = CoreDataSetStorage(
            directoryURL: FileManager.default.temporaryDirectory,
            storageName: "\(UUID())"
        )
    }

    override func tearDownWithError() throws {
        try storage.clear().wait()
    }

    func test__set_replaces_existing_values() throws {
        try storage.set([SetValue(id: 0), SetValue(id: 1)]).wait()

        let expected: Set<SetValue> = [SetValue(id: 2), SetValue(id: 3)]
        try storage.set(expected).wait()

        XCTAssertEqual(try storage.get().wait(), expected)
        XCTAssertEqual(try storage.count().wait(), expected.count)
    }

    func test__set_empty_clears_existing_values() throws {
        try storage.set([SetValue(id: 0)]).wait()

        try storage.set([]).wait()

        XCTAssertEqual(try storage.get().wait(), [])
        XCTAssertEqual(try storage.count().wait(), 0)
        XCTAssertEqual(try storage.size().wait().byte, 0)
    }

    func test__add() throws {
        let existingValue = SetValue(id: 0)
        let newValue = SetValue(id: 1)
        try storage.set([existingValue]).wait()

        try storage.add(existingValue).wait()
        try storage.add(newValue).wait()

        XCTAssertEqual(try storage.get().wait(), [existingValue, newValue])
        XCTAssertEqual(try storage.count().wait(), 2)
    }

    func test__delete() throws {
        let deletedValue = SetValue(id: 0)
        let remainingValue = SetValue(id: 1)
        try storage.set([deletedValue, remainingValue]).wait()

        try storage.delete(deletedValue).wait()
        try storage.delete(SetValue(id: 2)).wait()

        XCTAssertEqual(try storage.get().wait(), [remainingValue])
        XCTAssertEqual(try storage.count().wait(), 1)
    }

    func test__contains() throws {
        let existingValue = SetValue(id: 0)
        try storage.set([existingValue]).wait()

        XCTAssertTrue(try storage.contains(existingValue).wait())
        XCTAssertFalse(try storage.contains(SetValue(id: 1)).wait())
    }

    func test__contains_value_from_legacy_local_database() throws {
        let storageName = "\(UUID())"
        let legacyData = Data(#"{"second":2,"first":1}"#.utf8)
        try createLegacyStorage(storageName: storageName, data: legacyData)

        let storage = CoreDataSetStorage<LegacySetValue>(
            directoryURL: FileManager.default.temporaryDirectory,
            storageName: storageName
        )
        let existingValue = LegacySetValue(first: 1, second: 2)

        XCTAssertEqual(try storage.get().wait(), [existingValue])
        XCTAssertTrue(try storage.contains(existingValue).wait())
        XCTAssertFalse(
            try storage.contains(LegacySetValue(first: 1, second: 3)).wait()
        )

        let newValue = LegacySetValue(first: 3, second: 4)
        try storage.add(existingValue).wait()
        try storage.add(newValue).wait()
        XCTAssertEqual(try storage.get().wait(), [existingValue, newValue])

        try storage.delete(existingValue).wait()
        XCTAssertEqual(try storage.get().wait(), [newValue])
        try storage.delete(newValue).wait()
        XCTAssertEqual(try storage.get().wait(), [])

        try storage.set([existingValue]).wait()
        XCTAssertTrue(try storage.contains(existingValue).wait())
        try storage.clear().wait()
    }

    func test__set_and_get_100_000_values() throws {
        let expected = Set((0 ..< 100_000).map(SetValue.init(id:)))

        try storage.set(expected).wait()
        let actual = try storage.get().wait()

        XCTAssertEqual(actual, expected)
        XCTAssertEqual(try storage.count().wait(), expected.count)
        XCTAssertTrue(try storage.contains(SetValue(id: 99_999)).wait())
        XCTAssertFalse(try storage.contains(SetValue(id: 100_000)).wait())
    }
}

private extension CoreDataSetStorageTest {
    func createLegacyStorage(storageName: String, data: Data) throws {
        let schema = LegacyCoreDataSetStorageSchema()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(storageName)_Version1")
        let container = NSPersistentContainer(
            name: storageName,
            managedObjectModel: schema.model
        )
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: url)
        ]

        let loadExpectation = expectation(description: "load legacy persistent store")
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5)
        if let loadError {
            throw loadError
        }

        let context = container.newBackgroundContext()
        try context.performAndWait {
            let item = SabyCoreDataSetStorageItemVersion1(
                entity: schema.entity,
                insertInto: context
            )
            item.data = data
            item.byte = data.count
            try context.save()
        }

        for store in container.persistentStoreCoordinator.persistentStores {
            try container.persistentStoreCoordinator.remove(store)
        }
    }
}

private final class LegacyCoreDataSetStorageSchema {
    let entity: NSEntityDescription
    let model: NSManagedObjectModel

    init() {
        let dataAttribute = NSAttributeDescription()
        dataAttribute.name = "data"
        dataAttribute.attributeType = .binaryDataAttributeType

        let byteAttribute = NSAttributeDescription()
        byteAttribute.name = "byte"
        byteAttribute.attributeType = .integer64AttributeType

        let entity = NSEntityDescription()
        entity.name = "SabyCoreDataSetStorageItemVersion1"
        entity.managedObjectClassName = "SabyCoreDataSetStorageItemVersion1"
        entity.properties = [dataAttribute, byteAttribute]

        let model = NSManagedObjectModel()
        model.entities = [entity]

        self.entity = entity
        self.model = model
    }
}
