//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import SabyConcurrency
import CoreData

public typealias CoreDataStorageDatable = KeyIdentifiable & NSManagedObject & CoreDataStorageDataUpdater

public protocol CoreDataStorageDataUpdater {
    func updateData(_ mock: Self)
}

public struct CoreDataFetchPointer {
    let bundle: Bundle
    let modelName: String
}

fileprivate struct CoreDataResource {
    let rawObjectPointer: CoreDataFetchPointer
    let container: NSPersistentContainer
}

fileprivate final class CoreDataContextManager {
    static var shared = CoreDataContextManager()
    
    /// Using for making a ``NSPersistentContainer`` on Main thread to lock. Might of crash to accessing loadPersistentStores method in multi-threaded environment.
    let locker = Lock()
    
    var storages: [String: any ArrayStorage] = [:]
    var resource: CoreDataResource?
}

// MARK: CoreDataArrayStorage
/// ``CoreDataArrayStorage`` running on asynchronously.
public final class CoreDataArrayStorage<Item> where Item: CoreDataStorageDatable {
    private var resource: CoreDataResource
    private let entityKeyName: String
    
    /// When a user append extra action after async method, using to ``perform(_ block: @escaping () -> Void)``.
    public let context: NSManagedObjectContext
    
    /// Just for create temporary NSManagedObject instance. more desctiption is refer to ``NSManagedObjectContext`` initializer.
    public let mockContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    /// Initializer. make a new context though the container in resource(``CoreDataResource``) parameters.
    ///
    /// - Parameters:
    ///   - entityKeyName:Use the filtering key for fetching data. this same to ``create(objectPointer:entityKeyName:)``
    ///   ``entityKeyName`` parameters.
    ///   - resource:Used for making new context. (and not using this variable directly.)
    private init(entityKeyName: String, resource: CoreDataResource) {
        self.entityKeyName = entityKeyName
        self.resource = resource
        self.context = resource.container.newBackgroundContext()
        self.context.automaticallyMergesChangesFromParent = true
    }
    
    /// Is substituted for initializer. because a ``loadPersistentStores`` in ``NSPersistentContext`` method is asyncronize.
    ///
    /// private class method ``create(objectPointer:entityKeyName:)`` return type is ``Promise<CoreDataResource>``.
    /// and Convert to Promise<CoreDataArrayStorage>.
    ///
    /// - Parameters:
    ///   - objectPointer: Bundle Target with CoreData model Name to load.
    ///   - entityKeyName: Use the filtering key for fetching data. this parameter is key column name. referring to ``NSPredicate``
    /// - Returns: Async(Promise) result object a CoreDataArrayStorage. Plus, consider an **exception** while in create instance.
    public class func create(objectPointer: CoreDataFetchPointer, entityKeyName: String) -> Promise<CoreDataArrayStorage> {
        let objectKeyID = String(describing: Item.self)
        
        return create(objectPointer: objectPointer)
            .then {
                if
                    let arrayStorage = CoreDataContextManager.shared.storages[objectKeyID],
                    let storage = arrayStorage as? CoreDataArrayStorage<Item> {
                    return storage
                }
                
                let storage = CoreDataArrayStorage<Item>(entityKeyName: entityKeyName, resource: $0)
                CoreDataContextManager.shared.storages[objectKeyID] = storage
                return storage
            }
    }
    
    private class func create(objectPointer: CoreDataFetchPointer) -> Promise<CoreDataResource> {
        Promise<NSPersistentContainer>(on: .main) {
            CoreDataContextManager.shared.locker.lock()
            
            if let container = CoreDataContextManager.shared.resource?.container {
                return container.toPromise
            }
            
            let container = try NSPersistentContainer(
                name: objectPointer.modelName,
                managedObjectModel: fetchManagedObjectModel(objectPointer)
            )
            
            return container.loadPersistentStores()
        }
        .then {
            let resource = CoreDataResource(
                rawObjectPointer: objectPointer,
                container: $0
            )
            CoreDataContextManager.shared.resource = resource
            return resource
        }
        .finally {
            CoreDataContextManager.shared.locker.unlock()
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
        
        let predicate = NSPredicate(format: "\(entityKeyName) == %@", keyString)
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
    
    public func save() throws {
        try self.context.save()
    }
}

extension CoreDataArrayStorage {
    func removeAll() throws {
        _ = try? context.execute(NSBatchDeleteRequest(fetchRequest: fetchRequest()))
    }
}

extension CoreDataArrayStorage {
    private class func fetchManagedObjectModel(_ from: CoreDataFetchPointer) throws -> NSManagedObjectModel {
        guard
            let url = from.bundle.url(forResource: from.modelName, withExtension: "momd"),
            FileManager.default.fileExists(atPath: url.path),
            let managedObjectModel = NSManagedObjectModel(contentsOf: url)
        else {
            throw URLError(.badURL)
        }
        
        return managedObjectModel
    }
    
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
        return (self.init(entity: description, insertInto: context) as? O)
    }
}

// MARK: - NSManagedObject
fileprivate extension NSPersistentContainer {
    
    /// It's same to `loadPersistentStores:CompletionHandler` method. Is converted a completionHandler to Promise
    /// - Returns: loaded `NSPersistentContainer`.
    func loadPersistentStores() -> Promise<NSPersistentContainer> {
        return Promise(on: .main) { resolve, reject in
            self.loadPersistentStores { _, error in
                guard let error = error else {
                    resolve(self)
                    return
                }
                reject(error)
            }
        }
    }
    
    var toPromise: Promise<NSPersistentContainer> {
        Promise(on: .main) { self }
    }
}
