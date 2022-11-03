//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import SabyConcurrency
import CoreData

public typealias CoreDataValue = KeyIdentifiable & NSManagedObject & ManagedObjectUpdater

public protocol ManagedObjectUpdater {
    func updateData(_ mock: Self)
}

public struct CoreDataRawObjectPointer: Equatable {
    let bundle: Bundle
    let modelName: String
}

fileprivate struct CoreDataResource {
    let rawObjectPointer: CoreDataRawObjectPointer
    let container: NSPersistentContainer
}

fileprivate final class CoreDataContextManager {
    static var shared = CoreDataContextManager()
    var data: CoreDataResource?
}

// MARK: CoreDataArrayStorage
public final class CoreDataArrayStorage<Item> where Item: CoreDataValue {
    private var resource: CoreDataResource
    private let entityName: String
    
    public let context: NSManagedObjectContext
    public let mockContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    fileprivate init(entityName: String, resource: CoreDataResource) {
        self.entityName = entityName
        self.resource = resource
        self.context = resource.container.newBackgroundContext()
        self.context.automaticallyMergesChangesFromParent = true
    }
    
    public class func create(objectPointer: CoreDataRawObjectPointer, entityName: String) -> Promise<CoreDataArrayStorage> {
        return create(objectPointer: objectPointer)
            .toStorage(entityName: entityName)
    }
    
    private class func create(objectPointer: CoreDataRawObjectPointer) -> Promise<CoreDataResource> {
        return Promise<CoreDataResource>(on: .main) { resolve, reject in
            if
                let managedData = CoreDataContextManager.shared.data,
                managedData.rawObjectPointer == objectPointer {
                resolve(managedData)
                return
            }
            
            guard
                let url = objectPointer.bundle.url(forResource: objectPointer.modelName, withExtension: "momd"),
                FileManager.default.fileExists(atPath: url.path),
                let managedObjectModel = NSManagedObjectModel(contentsOf: url)
            else {
                throw URLError(.badURL)
            }
            
            let container = NSPersistentContainer(
                name: objectPointer.modelName, managedObjectModel: managedObjectModel
            )
            
            container.loadPersistentStores { _, error in
                if let error = error {
                    reject(error)
                    return
                }
                
                let resource = CoreDataResource(
                    rawObjectPointer: objectPointer,
                    container: container
                )
                
                CoreDataContextManager.shared.data = resource
                resolve(resource)
            }
        }
    }
}

extension CoreDataArrayStorage: ArrayStorage {
    public typealias Value = Item
    
    public func push(_ value: Item) {
        guard let item: Item = Item.creator(context: context) else { return }
        item.updateData(value)
    }
    
    public func delete(_ value: Item) {
        context.delete(value)
    }
    
    public func get(key: Item.Key) -> Item? {
        let keyString: CVarArg
        switch key {
        case let key as UUID: keyString = (key as CVarArg)
        default: keyString = String(describing: key)
        }
        
        let predicate = NSPredicate(format: "\(entityName) == %@", keyString)
        print(predicate.predicateFormat)
        return getAll(predicate: predicate).first
    }
    
    public func get(limit: GetLimit) -> [Item] {
        switch limit {
        case .unlimited:
            return getAll()
        case .count(let limit):
            return getAll(limit: Int(limit % .max))
        }
    }
    
    public func nonPromiseSave() {
        try? self.context.save()
    }
    
    public func save() -> Promise<Void> {
        return Promise<Void> {
            try self.context.save()
        }
    }
}

extension CoreDataArrayStorage {
    func removeAll() throws {
        let request = self.fetchRequest()
        context.performAndWait({
            _ = try? context.execute(NSBatchDeleteRequest(fetchRequest: request))
        })
    }
}

extension CoreDataArrayStorage {
    private func fetchRequest(limit: Int? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let result = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Item.self))
        if let limit = limit { result.fetchLimit = limit }
        return result
    }
    
    private func getAll(predicate: NSPredicate? = nil, limit: Int? = nil) -> [Item] {
        let request = fetchRequest(limit: limit)
        request.predicate = predicate
        let items = try? context.fetch(request) as? [Item]
        return items ?? []
    }
}

// MARK: - NSManagedObject
fileprivate extension NSManagedObject {
    static func creator<O>(context: NSManagedObjectContext) -> O? {
        guard
            let description = NSEntityDescription.entity(
                forEntityName: String(describing: self),
                in: context
            )
        else { return nil }
        return (self.init(entity: description, insertInto: context) as! O)
    }
}

// MARK: - Promise
fileprivate extension Promise where Value == CoreDataResource {
    func toStorage<Item: CoreDataValue>(entityName: String) -> Promise<CoreDataArrayStorage<Item>> {
        self.then { resource in
            let storage = CoreDataArrayStorage<Item>(entityName: entityName, resource: resource)
            return Promise<CoreDataArrayStorage>(on: .main) {
                return storage
            }
        }
    }
}
