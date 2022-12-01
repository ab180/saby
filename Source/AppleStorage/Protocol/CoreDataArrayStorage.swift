//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import SabyConcurrency
import SabySafe
import CoreData

public typealias CoreDataStorageDatable = KeyIdentifiable & NSManagedObject & CoreDataStorageDataUpdater

public protocol CoreDataStorageDataUpdater {
    func updateData(_ mock: Self)
}

public enum CoreDataStorageError: Error {
    case badURL
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
    
    /// Using for making a ``NSPersistentContainer`` on Main thread to lock.
    /// Might of crash to accessing loadPersistentStores method in multi-threaded environment.
    let locker = Lock()
    
    var storages: [String: any ArrayStorage] = [:]
    var resource: CoreDataResource?
}

// MARK: - CoreDataArrayStorage
/// ``CoreDataArrayStorage`` running on asynchronously.
public final class CoreDataArrayStorage<Item> where Item: CoreDataStorageDatable {
    private var resource: CoreDataResource
    private let entityKeyName: String
    
    /// When a user append extra action after async method, using to ``perform(_ block: @escaping () -> Void)``.
    public let context: NSManagedObjectContext
    
    /// Just for create temporary NSManagedObject instance. more description is refer to ``NSManagedObjectContext`` initializer.
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
        context = resource.container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
    }
    
    /// Is substituted for initializer. because a ``loadPersistentStores`` in ``NSPersistentContext`` method is synchronize.
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

        return create(objectPointer: objectPointer).then {
            if let arrayStorage = CoreDataContextManager.shared.storages[objectKeyID],
               let storage = arrayStorage as? CoreDataArrayStorage<Item> {
                return storage
            }

            let storage = CoreDataArrayStorage<Item>(entityKeyName: entityKeyName, resource: $0)
            CoreDataContextManager.shared.storages[objectKeyID] = storage
            return storage
        }
    }
    
    private class func create(objectPointer: CoreDataFetchPointer) -> Promise<CoreDataResource> {
        Promise {
            CoreDataContextManager.shared.locker.lock()
            
            if let resource = CoreDataContextManager.shared.resource {
                return resource
            }
            
            let container = try NSPersistentContainer(
                name: objectPointer.modelName,
                managedObjectModel: fetchManagedObjectModel(objectPointer)
            )
            
            return CoreDataResource(
                rawObjectPointer: objectPointer,
                container: container
            )
        }.then {
            return loadContext(resource: $0)
        }.then {
            CoreDataContextManager.shared.resource = $0
            return $0
        } .finally {
            CoreDataContextManager.shared.locker.unlock()
        }
    }
    
    private class func loadContext(resource: CoreDataResource) -> Promise<CoreDataResource> {
        return Promise<CoreDataResource> { resolve, reject in
            
            if let resource = CoreDataContextManager.shared.resource {
                resolve(resource)
                return
            }
            
            resource.container.loadPersistentStores { _, error in
                if let error = error {
                    reject(error)
                    return
                }
                
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
        context.perform {
            self.context.delete(value)
        }
    }
    
    public func get(key: Item.Key) -> Promise<Item> {
        let keyString: CVarArg
        switch key {
        case let key as UUID: keyString = (key as CVarArg)
        default: keyString = String(describing: key)
        }
        
        let predicate = NSPredicate(format: "\(entityKeyName) == %@", keyString)
        
        return Promise {
            self.getAll(predicate: predicate).then {
                try $0.first ?? throwing()
            }
        }
    }
    
    public func get(limit: GetLimit) -> Promise<[Item]> {
        switch limit {
        case .unlimited:
            return getAll()
        case .count(let limit):
            return getAll(limit: Int(limit % .max))
        }
    }
    
    public func save() -> Promise<Void> {
        return Promise { resolve, reject in
            self.context.perform {
                do {
                    try self.context.save()
                    resolve(())
                } catch { reject(error) }
            }
        }
    }
}

extension CoreDataArrayStorage {
    func removeAll() throws {
        context.perform {
            _ = try? self.context.execute(NSBatchDeleteRequest(fetchRequest: self.fetchRequest()))
        }
    }
}

extension CoreDataArrayStorage {
    private class func fetchManagedObjectModel(_ from: CoreDataFetchPointer) throws -> NSManagedObjectModel {
        guard
            let url = from.bundle.url(forResource: from.modelName, withExtension: "momd"),
            FileManager.default.fileExists(atPath: url.path),
            let managedObjectModel = NSManagedObjectModel(contentsOf: url)
        else {
            throw CoreDataStorageError.badURL
        }
        
        return managedObjectModel
    }
    
    private func fetchRequest(limit: Int? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let result = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Item.self))
        if let limit = limit { result.fetchLimit = limit }
        return result
    }
    
    private func getAll(predicate: NSPredicate? = nil, limit: Int? = nil) -> Promise<[Item]> {
        let fetchRequest = fetchRequest(limit: limit)
        fetchRequest.predicate = predicate
        
        return Promise { resolve, reject in
            self.context.perform {
                do {
                    guard let data = try self.context.fetch(fetchRequest) as? [Item] else {
                        resolve([])
                        return
                    }
                    
                    resolve(data)
                } catch {
                    reject(error)
                }
            }
        }
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
        Promise(on: .global()) { resolve, reject in
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
        Promise { self }
    }
}
