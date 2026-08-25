//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import CoreData

import SabyConcurrency
import SabySize
import SabyJSON

private let STORAGE_VERSION = "Version1"

public final class CoreDataArrayStorage<Value: Codable & KeyIdentifiable & Sendable>: ArrayStorage {
    typealias Context = NSManagedObjectContext
    typealias Item = SabyCoreDataArrayStorageItemVersion1

    let contextPromise: Promise<Context, Error>
    let tasks = PromiseTaskScope()

    public init(
        directoryURL: URL,
        storageName: String,
        migration: @escaping @Sendable () -> Promise<Void, Error>
    ) {
        self.contextPromise = Context.load(
            directoryURL: directoryURL,
            storageName: storageName,
            migration: migration
        )
    }
}

extension CoreDataArrayStorage {
    public func add(_ value: Value) -> Promise<Void, Error> {
        execute { context in
            let key = value.key
            let data = try JSONEncoder.acceptingNonConfirmingFloat().encode(value)
            let request = Self.createRequest(key: key) as NSFetchRequest<any NSFetchRequestResult>
            try context.executeDelete(request)

            let item = Item(
                entity: try context.arrayStorageEntity(),
                insertInto: context
            )
            item.key = key
            item.data = data
            item.date = Date()
            item.byte = data.count
        }
    }
    
    public func add(_ values: [Value]) -> Promise<Void, Error> {
        execute { context in
            let keys = values.map(\.key)
            let request = Self.createRequest(keys: keys) as NSFetchRequest<any NSFetchRequestResult>
            try context.executeDelete(request)

            let entity = try context.arrayStorageEntity()
            for value in values {
                let item = Item(entity: entity, insertInto: context)
                let data = try JSONEncoder.acceptingNonConfirmingFloat().encode(value)

                item.key = value.key
                item.data = data
                item.date = Date()
                item.byte = data.count
            }
        }
    }
    
    public func delete(key: UUID) -> Promise<Void, Error> {
        execute { context in
            let request = Self.createRequest(key: key) as NSFetchRequest<any NSFetchRequestResult>
            try context.executeDelete(request)
        }
    }
    
    public func delete(keys: [UUID]) -> Promise<Void, Error> {
        execute { context in
            let request = Self.createRequest(keys: keys) as NSFetchRequest<any NSFetchRequestResult>
            try context.executeDelete(request)
        }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { context in
            let request = Self.createRequest() as NSFetchRequest<any NSFetchRequestResult>
            try context.executeDelete(request)
        }
    }

    public func get(limit: Limit) -> Promise<[Value], Error> {
        let fetchLimit = limit.count
        return execute { context in
            let request: NSFetchRequest<Item> = Self.createRequest(fetchLimit: fetchLimit)
            return try context.fetch(request).map {
                try JSONDecoder.acceptingNonConfirmingFloat().decode(Value.self, from: $0.data)
            }
        }
    }

    public func get(limit: Limit, order: Order) -> Promise<[Value], Error> {
        let fetchLimit = limit.count
        let ascending = order == .oldest
        return execute { context in
            let request: NSFetchRequest<Item> = Self.createRequest(
                fetchLimit: fetchLimit,
                ascending: ascending
            )
            return try context.fetch(request).map {
                try JSONDecoder.acceptingNonConfirmingFloat().decode(Value.self, from: $0.data)
            }
        }
    }

    public func save() -> Promise<Void, Error> {
        execute { context in
            if context.hasChanges {
                try context.save()
            }
        }
    }
}

extension CoreDataArrayStorage {
    public func count() -> Promise<Int, Error> {
        execute { context in
            let request = Self.createCountRequest()
            let result = try context.fetch(request)
            guard let count = result.first else {
                throw CoreDataArrayStorageError.requestResultNotFound
            }

            return count.intValue
        }
    }
    
    public func size() -> Promise<Volume, Error> {
        execute { context in
            if context.hasChanges {
                try context.save()
            }

            let request = Self.createSizeRequest()
            let result = try context.fetch(request)
            guard let byte = result.first?["result"] as? NSNumber else {
                throw CoreDataArrayStorageError.requestResultNotFound
            }

            return Volume.byte(byte.doubleValue)
        }
    }
}

extension CoreDataArrayStorage {
    fileprivate static func createCountRequest() -> NSFetchRequest<NSNumber> {
        let request = NSFetchRequest<NSNumber>(entityName: Item.entityName)
        request.resultType = .countResultType

        return request
    }

    fileprivate static func createSizeRequest() -> NSFetchRequest<NSDictionary> {
        let byteExpression = NSExpression(forKeyPath: \SabyCoreDataArrayStorageItemVersion1.byte)
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [byteExpression])
        let sumDescription = NSExpressionDescription()
        sumDescription.expression = sumExpression
        sumDescription.name = "result"
        sumDescription.expressionResultType = .integer64AttributeType
        
        let request = NSFetchRequest<NSDictionary>(entityName: Item.entityName)
        request.propertiesToFetch = [sumDescription]
        request.resultType = .dictionaryResultType

        return request
    }

    fileprivate static func createRequest<Actual>(
        key: UUID? = nil,
        keys: [UUID]? = nil,
        fetchLimit: Int? = nil,
        ascending: Bool? = nil
    ) -> NSFetchRequest<Actual> {
        let request = NSFetchRequest<Actual>(entityName: Item.entityName)
        if let key {
            request.predicate = NSPredicate(format: "key = %@", key.uuidString)
        } else if let keys {
            request.predicate = NSPredicate(format: "key IN %@", keys.map(\.uuidString))
        }
        if let fetchLimit {
            request.fetchLimit = fetchLimit
        }
        if let ascending {
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: ascending)]
        }

        return request
    }
}

extension CoreDataArrayStorage {
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

extension NSManagedObjectContext {
    fileprivate func arrayStorageEntity() throws -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(
            forEntityName: SabyCoreDataArrayStorageItemVersion1.entityName,
            in: self
        ) else {
            throw CoreDataArrayStorageError.requestResultNotFound
        }
        return entity
    }

    fileprivate func executeDelete(_ request: NSFetchRequest<any NSFetchRequestResult>) throws {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        let result = try self.execute(deleteRequest)
        
        guard
            let objectIDs = (result as? NSBatchDeleteResult)?.result as? [NSManagedObjectID]
        else {
            throw CoreDataArrayStorageError.failedOnParsingDeleteResult
        }
        
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
            into: [self]
        )
    }
}

extension NSManagedObjectContext {
    static func load(
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
            let model = SabyCoreDataArrayStorageSchema().model

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

enum CoreDataArrayStorageError: Error {
    case failedOnParsingDeleteResult
    case requestResultNotFound
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
@objc(SabyCoreDataArrayStorageItemVersion1)
final class SabyCoreDataArrayStorageItemVersion1: NSManagedObject {
    static let entityName = String(describing: SabyCoreDataArrayStorageItemVersion1.self)

    @NSManaged var key: UUID
    @NSManaged var data: Data
    @NSManaged var date: Date
    @NSManaged var byte: Int
}

final class SabyCoreDataArrayStorageSchema {
    let model: NSManagedObjectModel
    
    init() {
        let keyAttribute = NSAttributeDescription()
        keyAttribute.name = "key"
        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *) {
            keyAttribute.type = .uuid
        } else {
            keyAttribute.attributeType = .UUIDAttributeType
        }
        
        let dataAttribute = NSAttributeDescription()
        dataAttribute.name = "data"
        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *) {
            dataAttribute.type = .binaryData
        } else {
            dataAttribute.attributeType = .binaryDataAttributeType
        }
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *) {
            dateAttribute.type = .date
        } else {
            dateAttribute.attributeType = .dateAttributeType
        }
        
        let byteAttribute = NSAttributeDescription()
        byteAttribute.name = "byte"
        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *) {
            byteAttribute.type = .integer64
        } else {
            byteAttribute.attributeType = .integer64AttributeType
        }
        
        let itemEntity = NSEntityDescription()
        itemEntity.name = SabyCoreDataArrayStorageItemVersion1.entityName
        itemEntity.managedObjectClassName = SabyCoreDataArrayStorageItemVersion1.entityName
        itemEntity.properties = [
            keyAttribute,
            dataAttribute,
            dateAttribute,
            byteAttribute
        ]
        
        let model = NSManagedObjectModel()
        model.entities = [
            itemEntity
        ]
        
        self.model = model
    }
}

private extension Limit {
    var count: Int? {
        guard case .count(let count) = self else { return nil }
        return count
    }
}
