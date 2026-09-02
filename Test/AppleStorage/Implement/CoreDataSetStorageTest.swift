//
//  CoreDataSetStorageTest.swift
//  SabyAppleStorageTest
//

#if canImport(CoreData)

import CoreData
import Testing
@testable import SabyAppleStorage

private struct SetValue: Codable, Hashable, Sendable {
    let id: Int
}

private struct LegacySetValue: Codable, Hashable, Sendable {
    let first: Int
    let second: Int
}

struct CoreDataSetStorageTest {
    private let storage: CoreDataSetStorage<SetValue>

    init() {
        storage = CoreDataSetStorage(
            directoryURL: FileManager.default.temporaryDirectory,
            storageName: "\(UUID())"
        )
    }

    @Test func set_replaces_existing_values() async throws {
        try await storage.set([SetValue(id: 0), SetValue(id: 1)]).value()

        let expected: Set<SetValue> = [SetValue(id: 2), SetValue(id: 3)]
        try await storage.set(expected).value()

        #expect(try await storage.get().value() == expected)
        #expect(try await storage.count().value() == expected.count)
    }

    @Test func set_empty_clears_existing_values() async throws {
        try await storage.set([SetValue(id: 0)]).value()

        try await storage.set([]).value()

        #expect(try await storage.get().value() == [])
        #expect(try await storage.count().value() == 0)
        #expect(try await storage.size().value().byte == 0)
    }

    @Test func add() async throws {
        let existingValue = SetValue(id: 0)
        let newValue = SetValue(id: 1)
        try await storage.set([existingValue]).value()

        try await storage.add(existingValue).value()
        try await storage.add(newValue).value()

        #expect(try await storage.get().value() == [existingValue, newValue])
        #expect(try await storage.count().value() == 2)
    }

    @Test func delete() async throws {
        let deletedValue = SetValue(id: 0)
        let remainingValue = SetValue(id: 1)
        try await storage.set([deletedValue, remainingValue]).value()

        try await storage.delete(deletedValue).value()
        try await storage.delete(SetValue(id: 2)).value()

        #expect(try await storage.get().value() == [remainingValue])
        #expect(try await storage.count().value() == 1)
    }

    @Test func contains() async throws {
        let existingValue = SetValue(id: 0)
        try await storage.set([existingValue]).value()

        #expect(try await storage.contains(existingValue).value())
        let containsMissingValue = try await storage.contains(SetValue(id: 1)).value()
        #expect(!containsMissingValue)
    }

    @Test func contains_value_from_legacy_local_database() async throws {
        let storageName = "\(UUID())"
        let legacyData = Data(#"{"second":2,"first":1}"#.utf8)
        try await createLegacyStorage(storageName: storageName, data: legacyData)

        let storage = CoreDataSetStorage<LegacySetValue>(
            directoryURL: FileManager.default.temporaryDirectory,
            storageName: storageName
        )
        let existingValue = LegacySetValue(first: 1, second: 2)

        #expect(try await storage.get().value() == [existingValue])
        #expect(try await storage.contains(existingValue).value())
        #expect(!(try await storage.contains(LegacySetValue(first: 1, second: 3)).value()))

        let newValue = LegacySetValue(first: 3, second: 4)
        try await storage.add(existingValue).value()
        try await storage.add(newValue).value()
        #expect(try await storage.get().value() == [existingValue, newValue])

        try await storage.delete(existingValue).value()
        #expect(try await storage.get().value() == [newValue])
        try await storage.delete(newValue).value()
        #expect(try await storage.get().value() == [])

        try await storage.set([existingValue]).value()
        #expect(try await storage.contains(existingValue).value())
        try await storage.clear().value()
    }

    @Test func set_and_get_100_000_values() async throws {
        let expected = Set((0 ..< 100_000).map(SetValue.init(id:)))

        try await storage.set(expected).value()
        let actual = try await storage.get().value()

        #expect(actual == expected)
        #expect(try await storage.count().value() == expected.count)
        #expect(try await storage.contains(SetValue(id: 99_999)).value())
        let containsOutOfRangeValue = try await storage.contains(SetValue(id: 100_000)).value()
        #expect(!containsOutOfRangeValue)
    }
}

private extension CoreDataSetStorageTest {
    func createLegacyStorage(storageName: String, data: Data) async throws {
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

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        let context = container.newBackgroundContext()
        try context.performAndWait {
            let entity = NSEntityDescription.entity(
                forEntityName: "SabyCoreDataSetStorageItemVersion1",
                in: context
            )!
            let item = SabyCoreDataSetStorageItemVersion1(
                entity: entity,
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

#endif
