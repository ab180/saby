//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import CoreData

import SabyConcurrency
import SabySafe
import SabySize
import SabyJSON

private let STORAGE_VERSION = "Version1"

public final class CoreDataArrayStorage<Value: Codable & KeyIdentifiable>: ArrayStorage {
    typealias Context = NSManagedObjectContext
    typealias Item = SabyCoreDataArrayStorageItemVersion1
    
    let entity: NSEntityDescription
    
    let contextLoad: () -> Promise<Context, Error>
    let contextPromise: Atomic<Promise<Context, Error>>
    
    let encoder = JSONEncoder.acceptingNonConfirmingFloat()
    let decoder = JSONDecoder.acceptingNonConfirmingFloat()
    
    public init(directoryURL: URL, storageName: String, migration: @escaping () -> Promise<Void, Error>) {
        let schema = SabyCoreDataArrayStorageSchema()
        
        self.entity = schema.entity
        
        self.contextLoad = {
            Context.load(
                directoryURL: directoryURL,
                storageName: storageName,
                migration: migration,
                model: schema.model
            )
        }
        self.contextPromise = Atomic(contextLoad())
    }
}

extension CoreDataArrayStorage {
    public func add(_ value: Value) -> Promise<Void, Error> {
        execute { context in
            let key = value.key
            let data = try self.encoder.encode(value)
            
            let request = self.createAnyRequest(key: key)
            try context.executeDelete(request)

            let item = SabyCoreDataArrayStorageItemVersion1(
                entity: self.entity,
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
            
            let request = self.createAnyRequest(keys: keys)
            try context.executeDelete(request)
            
            for value in values {
                let item = SabyCoreDataArrayStorageItemVersion1(
                    entity: self.entity,
                    insertInto: context
                )
                let data = try self.encoder.encode(value)
                
                item.key = value.key
                item.data = data
                item.date = Date()
                item.byte = data.count
            }
        }
    }
    
    public func delete(key: UUID) -> Promise<Void, Error> {
        execute { context in
            let request = self.createAnyRequest(key: key)
            try context.executeDelete(request)
        }
    }
    
    public func delete(keys: [UUID]) -> Promise<Void, Error> {
        execute { context in
            let request = self.createAnyRequest(keys: keys)
            try context.executeDelete(request)
        }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { context in
            let request = self.createAnyRequest()
            try context.executeDelete(request)
        }
    }

    public func get(key: UUID) -> Promise<Value?, Error> {
        execute { context in
            let request = self.createRequest(key: key)
            let items = try context.fetch(request)
            guard let data = items.first?.data else { return nil }
            let value = try self.decoder.decode(Value.self, from: data)

            return value
        }
    }
    
    public func get(limit: Limit) -> Promise<[Value], Error> {
        execute { context in
            let request = self.createRequest(limit: limit)
            let items = try context.fetch(request)
            var values: [Value] = []
            
            for item in items {
                let value = try self.decoder.decode(Value.self, from: item.data)
                values.append(value)
            }

            return values
        }
    }

    public func get(limit: Limit, order: Order) -> Promise<[Value], Error> {
        execute { context in
            let request = self.createRequest(limit: limit, order: order)
            let items = try context.fetch(request)
            var values: [Value] = []
            
            for item in items {
                let value = try self.decoder.decode(Value.self, from: item.data)
                values.append(value)
            }

            return values
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
            let request = self.createCountRequest()
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

            let request = self.createSizeRequest()
            let result = try context.fetch(request)
            guard let byte = result.first?["result"] as? NSNumber else {
                throw CoreDataArrayStorageError.requestResultNotFound
            }

            return Volume.byte(byte.doubleValue)
        }
    }
}

extension CoreDataArrayStorage {
    fileprivate func createCountRequest() -> NSFetchRequest<NSNumber> {
        let request = NSFetchRequest<NSNumber>()
        request.entity = entity
        request.resultType = .countResultType
        
        return request
    }
    
    fileprivate func createSizeRequest() -> NSFetchRequest<NSDictionary> {
        let byteExpression = NSExpression(forKeyPath: \SabyCoreDataArrayStorageItemVersion1.byte)
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [byteExpression])
        let sumDescription = NSExpressionDescription()
        sumDescription.expression = sumExpression
        sumDescription.name = "result"
        sumDescription.expressionResultType = .integer64AttributeType
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = entity
        request.propertiesToFetch = [sumDescription]
        request.resultType = .dictionaryResultType
        
        return request
    }
    
    fileprivate func createRequest() -> NSFetchRequest<Item> {
        createActualRequest()
    }
    
    fileprivate func createRequest(key: UUID) -> NSFetchRequest<Item> {
        createActualRequest(key: key)
    }
    
    fileprivate func createRequest(keys: [UUID]) -> NSFetchRequest<Item> {
        createActualRequest(keys: keys)
    }
    
    fileprivate func createRequest(limit: Limit) -> NSFetchRequest<Item> {
        createActualRequest(limit: limit)
    }
    
    fileprivate func createRequest(limit: Limit, order: Order) -> NSFetchRequest<Item> {
        createActualRequest(limit: limit, order: order)
    }
    
    fileprivate func createAnyRequest() -> NSFetchRequest<any NSFetchRequestResult> {
        createActualRequest()
    }
    
    fileprivate func createAnyRequest(key: UUID) -> NSFetchRequest<any NSFetchRequestResult> {
        createActualRequest(key: key)
    }
    
    fileprivate func createAnyRequest(keys: [UUID]) -> NSFetchRequest<any NSFetchRequestResult> {
        createActualRequest(keys: keys)
    }
    
    fileprivate func createAnyRequest(limit: Limit) -> NSFetchRequest<any NSFetchRequestResult> {
        createActualRequest(limit: limit)
    }
    
    fileprivate func createAnyRequest(limit: Limit, order: Order) -> NSFetchRequest<any NSFetchRequestResult> {
        createActualRequest(limit: limit, order: order)
    }
    
    private func createActualRequest<Actual>() -> NSFetchRequest<Actual> {
        let request = NSFetchRequest<Actual>()
        request.entity = self.entity
        
        return request
    }
    
    private func createActualRequest<Actual>(key: UUID) -> NSFetchRequest<Actual> {
        let request: NSFetchRequest<Actual> = createActualRequest()
        request.predicate = NSPredicate(format: "key = %@", key.uuidString)
        
        return request
    }
    
    private func createActualRequest<Actual>(keys: [UUID]) -> NSFetchRequest<Actual> {
        let request: NSFetchRequest<Actual> = createActualRequest()
        request.predicate = NSPredicate(format: "key IN %@", keys.map(\.uuidString))
        
        return request
    }
    
    private func createActualRequest<Actual>(limit: Limit) -> NSFetchRequest<Actual> {
        let request: NSFetchRequest<Actual> = createActualRequest()
        if case .count(let count) = limit {
            request.fetchLimit = Int(count)
        }
        
        return request
    }
    
    private func createActualRequest<Actual>(limit: Limit, order: Order) -> NSFetchRequest<Actual> {
        let request: NSFetchRequest<Actual> = createActualRequest(limit: limit)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: order == .oldest)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}

extension CoreDataArrayStorage {
    fileprivate func execute<Result>(
        block: @escaping (Context) throws -> Result
    ) -> Promise<Result, Error> {
        let loadPromiseCapture = self.contextPromise.mutate {
            let capture = !$0.isRejected ? $0 : contextLoad()
            return capture
        }
        
        return loadPromiseCapture.then { context in
            Promise<Result, Error> { resolve, reject in
                context.perform {
                    do {
                        resolve(try block(context))
                    }
                    catch {
                        reject(error)
                    }
                }
            }
        }
    }
}

extension NSManagedObjectContext {
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
        migration: @escaping () -> Promise<Void, Error>,
        model: NSManagedObjectModel
    ) -> Promise<NSManagedObjectContext, Error> {
        migration().then {
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

public enum CoreDataArrayStorageError: Error {
    case failedOnParsingDeleteResult
    case requestResultNotFound
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
@objc(SabyCoreDataArrayStorageItemVersion1)
final class SabyCoreDataArrayStorageItemVersion1: NSManagedObject {
    @NSManaged var key: UUID
    @NSManaged var data: Data
    @NSManaged var date: Date
    @NSManaged var byte: Int
}

final class SabyCoreDataArrayStorageSchema {
    let entity: NSEntityDescription
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
        itemEntity.name = String(describing: SabyCoreDataArrayStorageItemVersion1.self)
        itemEntity.managedObjectClassName = String(describing: SabyCoreDataArrayStorageItemVersion1.self)
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
        
        self.entity = itemEntity
        self.model = model
    }
}
