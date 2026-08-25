//
//  CoreDataSetStorage.swift
//  SabyAppleStorage
//

#if canImport(CoreData)
import CoreData

import SabyConcurrency
import SabyJSON
import SabySize

private let STORAGE_VERSION = "Version1"
private let STORAGE_ENCODING_VERSION_KEY = "SabyCoreDataSetStorageEncodingVersion"
private let STORAGE_ENCODING_VERSION = 1

public final class CoreDataSetStorage<Value: Codable & Hashable & Sendable>: SetStorage {
    typealias Context = NSManagedObjectContext

    let contextPromise: Promise<Context, Error>
    let tasks = PromiseTaskScope()

    public init(
        directoryURL: URL,
        storageName: String,
        migration: @escaping @Sendable () -> Promise<Void, Error>
    ) {
        self.contextPromise = Context.loadSetStorage(
            directoryURL: directoryURL,
            storageName: storageName,
            migration: migration
        )
    }
}

extension CoreDataSetStorage {
    public func set(_ values: Set<Value>) -> Promise<Void, Error> {
        execute { context in
            let encoder = Self.makeEncoder()
            let encodedValues = try values.map { value -> Data in
                try encoder.encode(value)
            }

            try context.executeSetStorageDelete(Self.createAnyRequest())

            if !encodedValues.isEmpty {
                try context.insertSetStorageItems(encodedValues: encodedValues)
            }

            try context.markSetStorageEncodingCurrent()
        }
    }

    public func add(_ value: Value) -> Promise<Void, Error> {
        execute { context in
            let data = try Self.makeEncoder().encode(value)
            let request = Self.createContainsRequest(data: data)

            if try context.fetch(request).isEmpty == false {
                return
            }

            let isEncodingCurrent = try context.isSetStorageEncodingCurrent()
            var storedValueCount = 0

            if !isEncodingCurrent {
                let decoder = JSONDecoder.acceptingNonConfirmingFloat()
                let dictionaries = try context.fetch(Self.createDataRequest())
                storedValueCount = dictionaries.count

                for dictionary in dictionaries {
                    guard let storedData = dictionary["data"] as? Data else {
                        throw CoreDataSetStorageError.requestResultNotFound
                    }

                    if try decoder.decode(Value.self, from: storedData) == value {
                        return
                    }
                }
            }

            try context.insertSetStorageItems(encodedValues: [data])

            if !isEncodingCurrent && storedValueCount == 0 {
                try context.markSetStorageEncodingCurrent()
            }
        }
    }

    public func delete(_ value: Value) -> Promise<Void, Error> {
        execute { context in
            let data = try Self.makeEncoder().encode(value)
            try context.executeSetStorageDelete(
                Self.createAnyRequest(data: data)
            )

            guard try context.isSetStorageEncodingCurrent() == false else {
                return
            }

            let items = try context.fetch(Self.createItemRequest())
            let decoder = JSONDecoder.acceptingNonConfirmingFloat()
            var hasChanges = false

            for item in items {
                if try decoder.decode(Value.self, from: item.data) == value {
                    context.delete(item)
                    hasChanges = true
                }
            }

            if hasChanges {
                try context.save()
            }
        }
    }

    public func get() -> Promise<Set<Value>, Error> {
        execute { context in
            let dictionaries = try context.fetch(Self.createDataRequest())
            let decoder = JSONDecoder.acceptingNonConfirmingFloat()
            var values = Set<Value>(minimumCapacity: dictionaries.count)

            for dictionary in dictionaries {
                guard let data = dictionary["data"] as? Data else {
                    throw CoreDataSetStorageError.requestResultNotFound
                }
                values.insert(try decoder.decode(Value.self, from: data))
            }

            return values
        }
    }

    public func contains(_ value: Value) -> Promise<Bool, Error> {
        execute { context in
            let data = try Self.makeEncoder().encode(value)
            let request = Self.createContainsRequest(data: data)

            if try context.fetch(request).isEmpty == false {
                return true
            }

            guard try context.isSetStorageEncodingCurrent() == false else {
                return false
            }

            let decoder = JSONDecoder.acceptingNonConfirmingFloat()
            let dictionaries = try context.fetch(Self.createDataRequest())
            for dictionary in dictionaries {
                guard let legacyData = dictionary["data"] as? Data else {
                    throw CoreDataSetStorageError.requestResultNotFound
                }

                if try decoder.decode(Value.self, from: legacyData) == value {
                    return true
                }
            }

            return false
        }
    }

    public func clear() -> Promise<Void, Error> {
        execute { context in
            try context.executeSetStorageDelete(Self.createAnyRequest())
            try context.markSetStorageEncodingCurrent()
        }
    }
}

extension CoreDataSetStorage {
    public func count() -> Promise<Int, Error> {
        execute { context in
            try context.count(for: Self.createAnyRequest())
        }
    }

    public func size() -> Promise<Volume, Error> {
        execute { context in
            let result = try context.fetch(Self.createSizeRequest())
            let byte = result.first?["result"] as? NSNumber ?? 0

            return Volume.byte(byte.doubleValue)
        }
    }
}

extension CoreDataSetStorage {
    fileprivate static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder.acceptingNonConfirmingFloat()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    fileprivate static func createAnyRequest() -> NSFetchRequest<any NSFetchRequestResult> {
        let request = NSFetchRequest<any NSFetchRequestResult>(
            entityName: SabyCoreDataSetStorageItemVersion1.entityName
        )

        return request
    }

    fileprivate static func createAnyRequest(
        data: Data
    ) -> NSFetchRequest<any NSFetchRequestResult> {
        let request = createAnyRequest()
        request.predicate = NSPredicate(format: "data == %@", data as NSData)

        return request
    }

    fileprivate static func createItemRequest() -> NSFetchRequest<SabyCoreDataSetStorageItemVersion1> {
        let request = NSFetchRequest<SabyCoreDataSetStorageItemVersion1>(
            entityName: SabyCoreDataSetStorageItemVersion1.entityName
        )

        return request
    }

    fileprivate static func createDataRequest() -> NSFetchRequest<NSDictionary> {
        let request = NSFetchRequest<NSDictionary>(
            entityName: SabyCoreDataSetStorageItemVersion1.entityName
        )
        request.propertiesToFetch = ["data"]
        request.resultType = .dictionaryResultType

        return request
    }

    fileprivate static func createContainsRequest(data: Data) -> NSFetchRequest<NSManagedObjectID> {
        let request = NSFetchRequest<NSManagedObjectID>(
            entityName: SabyCoreDataSetStorageItemVersion1.entityName
        )
        request.predicate = NSPredicate(format: "data == %@", data as NSData)
        request.fetchLimit = 1
        request.resultType = .managedObjectIDResultType

        return request
    }

    fileprivate static func createSizeRequest() -> NSFetchRequest<NSDictionary> {
        let byteExpression = NSExpression(forKeyPath: \SabyCoreDataSetStorageItemVersion1.byte)
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [byteExpression])
        let sumDescription = NSExpressionDescription()
        sumDescription.expression = sumExpression
        sumDescription.name = "result"
        sumDescription.expressionResultType = .integer64AttributeType

        let request = NSFetchRequest<NSDictionary>(
            entityName: SabyCoreDataSetStorageItemVersion1.entityName
        )
        request.propertiesToFetch = [sumDescription]
        request.resultType = .dictionaryResultType

        return request
    }
}

extension CoreDataSetStorage {
    fileprivate func execute<Result: Sendable>(
        block: @escaping @Sendable (Context) throws -> Result
    ) -> Promise<Result, Error> {
        let contextPromise = self.contextPromise

        return tasks.promise {
            let context = try await contextPromise.value(
                cancelOnTaskCancellation: false
            )
            return try await context.perform {
                try block(context)
            }
        }
    }
}

private extension NSManagedObjectContext {
    func insertSetStorageItems(
        encodedValues: [Data]
    ) throws {
        guard let entity = NSEntityDescription.entity(
            forEntityName: SabyCoreDataSetStorageItemVersion1.entityName,
            in: self
        ) else {
            throw CoreDataSetStorageError.requestResultNotFound
        }

        for data in encodedValues {
            let item = SabyCoreDataSetStorageItemVersion1(
                entity: entity,
                insertInto: self
            )
            item.data = data
            item.byte = data.count
        }

        do {
            try save()
        } catch {
            rollback()
            throw error
        }
    }

    func isSetStorageEncodingCurrent() throws -> Bool {
        let metadata = try setStorageMetadata()
        let version = metadata.values[STORAGE_ENCODING_VERSION_KEY] as? NSNumber

        return version?.intValue == STORAGE_ENCODING_VERSION
    }

    func markSetStorageEncodingCurrent() throws {
        var metadata = try setStorageMetadata()
        metadata.values[STORAGE_ENCODING_VERSION_KEY] = STORAGE_ENCODING_VERSION
        metadata.coordinator.setMetadata(metadata.values, for: metadata.store)
    }

    func setStorageMetadata() throws -> (
        coordinator: NSPersistentStoreCoordinator,
        store: NSPersistentStore,
        values: [String: Any]
    ) {
        guard
            let coordinator = persistentStoreCoordinator,
            let store = coordinator.persistentStores.first
        else {
            throw CoreDataSetStorageError.persistentStoreNotFound
        }

        return (
            coordinator,
            store,
            coordinator.metadata(for: store)
        )
    }

    func executeSetStorageDelete(
        _ request: NSFetchRequest<any NSFetchRequestResult>
    ) throws {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeStatusOnly

        guard
            let result = try execute(deleteRequest) as? NSBatchDeleteResult,
            result.result as? Bool == true
        else {
            throw CoreDataSetStorageError.batchDeleteFailed
        }
    }

    static func loadSetStorage(
        directoryURL: URL,
        storageName: String,
        migration: @Sendable () -> Promise<Void, Error>
    ) -> Promise<NSManagedObjectContext, Error> {
        return migration().then {
            let fileManager = FileManager.default

            guard directoryURL.isFileURL else {
                throw StorageError.directoryURLIsNotFileURL
            }

            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true
                )
            }

            let url = directoryURL.appendingPathComponent("\(storageName)_\(STORAGE_VERSION)")
            let model = SabyCoreDataSetStorageSchema().model
            let container = NSPersistentContainer(
                name: storageName,
                managedObjectModel: model
            )
            let storeDescription = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [storeDescription]

            return Promise { resolve, reject in
                container.loadPersistentStores { _, error in
                    if let error {
                        reject(error)
                        return
                    }
                    resolve(container.newBackgroundContext())
                }
            }
        }
    }
}

enum CoreDataSetStorageError: Error {
    case batchDeleteFailed
    case persistentStoreNotFound
    case requestResultNotFound
}

@objc(SabyCoreDataSetStorageItemVersion1)
final class SabyCoreDataSetStorageItemVersion1: NSManagedObject {
    static let entityName = String(describing: SabyCoreDataSetStorageItemVersion1.self)

    @NSManaged var data: Data
    @NSManaged var byte: Int
}

final class SabyCoreDataSetStorageSchema {
    let model: NSManagedObjectModel

    init() {
        let dataAttribute = NSAttributeDescription()
        dataAttribute.name = "data"
        dataAttribute.type = .binaryData

        let byteAttribute = NSAttributeDescription()
        byteAttribute.name = "byte"
        byteAttribute.type = .integer64

        let itemEntity = NSEntityDescription()
        itemEntity.name = SabyCoreDataSetStorageItemVersion1.entityName
        itemEntity.managedObjectClassName = SabyCoreDataSetStorageItemVersion1.entityName
        itemEntity.properties = [
            dataAttribute,
            byteAttribute
        ]
        itemEntity.indexes = [
            NSFetchIndexDescription(
                name: "SabyCoreDataSetStorageDataIndex",
                elements: [
                    NSFetchIndexElementDescription(
                        property: dataAttribute,
                        collationType: .binary
                    )
                ]
            )
        ]

        let model = NSManagedObjectModel()
        model.entities = [itemEntity]

        self.model = model
    }
}
#endif
