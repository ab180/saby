//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import CoreData

import SabyConcurrency
import SabySafe

public final class CoreDataArrayStorage<Value: Codable>: ArrayStorage {
    typealias Context = NSManagedObjectContext
    typealias Item = SabyCoreDataArrayStorageItem
    
    let name: String
    let model: NSManagedObjectModel
    let entity: NSEntityDescription
    
    let loadPromise: Atomic<Promise<Context, Error>>
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    public init(name: String) {
        let schema = SabyCoreDataArrayStorageSchema()
        
        self.name = name
        self.model = schema.model
        self.entity = schema.entity
        
        self.loadPromise = Atomic(Context.load(
            name: name,
            model: model
        ))
    }
}

extension CoreDataArrayStorage {
    public func add(_ value: Value) -> Promise<UUID, Error> {
        execute { context in
            let key = UUID()
            let data = try self.encoder.encode(value)
            
            let request = self.createAnyRequest(key: key)
            try context.executeDelete(request: request)

            let item = SabyCoreDataArrayStorageItem(
                entity: self.entity,
                insertInto: context
            )
            item.key = key
            item.data = data

            return key
        }
    }
    
    public func delete(key: UUID) -> Promise<Void, Error> {
        execute { context in
            let request = self.createAnyRequest(key: key)
            try context.executeDelete(request: request)
        }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { context in
            let request = self.createAnyRequest(limit: .unlimited)
            try context.executeDelete(request: request)
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

    public func get(limit: GetLimit) -> Promise<[Value], Error> {
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

    public func save() -> Promise<Void, Error> {
        execute { context in
            try context.save()
        }
    }
}

extension CoreDataArrayStorage {
    fileprivate func createRequest(key: UUID) -> NSFetchRequest<Item> {
        createActualRequest(key: key)
    }
    
    fileprivate func createRequest(limit: GetLimit) -> NSFetchRequest<Item> {
        createActualRequest(limit: limit)
    }
    
    fileprivate func createAnyRequest(key: UUID) -> NSFetchRequest<any NSFetchRequestResult> {
        createActualRequest(key: key)
    }
    
    fileprivate func createAnyRequest(limit: GetLimit) -> NSFetchRequest<any NSFetchRequestResult> {
        createActualRequest(limit: limit)
    }
    
    private func createActualRequest<Actual>(key: UUID) -> NSFetchRequest<Actual> {
        let request = NSFetchRequest<Actual>()
        request.entity = self.entity
        request.predicate = NSPredicate(format: "key = %@", key.uuidString)
        
        return request
    }
    
    private func createActualRequest<Actual>(limit: GetLimit) -> NSFetchRequest<Actual> {
        let request = NSFetchRequest<Actual>()
        request.entity = self.entity
        if case .count(let count) = limit {
            request.fetchLimit = Int(count)
        }
        
        return request
    }
}

extension CoreDataArrayStorage {
    fileprivate func execute<Result>(
        block: @escaping (Context) throws -> Result
    ) -> Promise<Result, Error> {
        let loadPromiseCapture = self.loadPromise.mutate {
            let capture = !$0.isRejected ? $0 : Context.load(
                name: self.name,
                model: self.model
            )
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
    fileprivate func executeDelete(request: NSFetchRequest<any NSFetchRequestResult>) throws {
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
        name: String,
        model: NSManagedObjectModel
    ) -> Promise<NSManagedObjectContext, Error> {
        Promise { resolve, reject in
            let container = NSPersistentContainer(
                name: name,
                managedObjectModel: model
            )

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

public enum CoreDataArrayStorageError: Error {
    case failedOnParsingDeleteResult
}

@objc(SabyCoreDataArrayStorageItem)
final class SabyCoreDataArrayStorageItem: NSManagedObject {
    @NSManaged var key: UUID
    @NSManaged var data: Data
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
        
        let itemEntity = NSEntityDescription()
        itemEntity.name = String(describing: SabyCoreDataArrayStorageItem.self)
        itemEntity.managedObjectClassName = String(describing: SabyCoreDataArrayStorageItem.self)
        itemEntity.properties = [
            keyAttribute,
            dataAttribute
        ]
        
        let model = NSManagedObjectModel()
        model.entities = [
            itemEntity
        ]
        
        self.entity = itemEntity
        self.model = model
    }
}
