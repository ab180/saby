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

fileprivate final class CoreDataContextManager {
    static var shared = CoreDataContextManager()
    
    /// Using for making a ``NSPersistentContainer`` on Main thread to lock.
    /// Might of crash to accessing loadPersistentStores method in multi-threaded environment.
    let locker = Lock()
    
    var storages: [String: any ArrayStorage] = [:]
    var loadedContainer: NSPersistentContainer?
}

// MARK: - CoreDataArrayStorage
/// ``CoreDataArrayStorage`` running on asynchronously.
public final class CoreDataArrayStorage<Item> where Item: CoreDataStorageDatable {
    private var container: NSPersistentContainer
    private let entityKeyName: String
    
    /// When a user append extra action after async method, using to ``perform(_ block: @escaping () -> Void)``.
    public let context: NSManagedObjectContext
    
    /// Just for create temporary NSManagedObject instance. more description is refer to ``NSManagedObjectContext`` initializer.
    public let mockContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    /// Initializer. make a new context though the container in resource(``CoreDataResource``) parameters.
    ///
    /// - Parameters:
    ///   - entityKeyName:Use the filtering key for fetching data. this same to ``create(objectDescriptor:entityKeyName:)``
    ///   ``entityKeyName`` parameters.
    ///   - resource:Used for making new context. (and not using this variable directly.)
    private init(entityKeyName: String, container: NSPersistentContainer) {
        self.entityKeyName = entityKeyName
        self.container = container
        context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
    }
    
    deinit {
        let objectKeyID = String(describing: Item.self)
        CoreDataContextManager.shared.storages[objectKeyID] = nil
    }
    
    /// Is substituted for initializer. because a ``loadPersistentStores`` in ``NSPersistentContext`` method is synchronize.
    ///
    /// private class method ``create(objectDescriptor:entityKeyName:)`` return type is ``Promise<CoreDataResource>``.
    /// and Convert to Promise<CoreDataArrayStorage>.
    ///
    /// - Parameters:
    ///   - objectDescriptor: Bundle Target with CoreData model Name to load.
    ///   - entityKeyName: Use the filtering key for fetching data. this parameter is key column name. referring to ``NSPredicate``
    /// - Returns: Async(Promise) result object a CoreDataArrayStorage. Plus, consider an **exception** while in create instance.
    public static func create(modelName: String, bundle: Bundle, entityKeyName: String) -> Promise<CoreDataArrayStorage> {
        return convertContainerToStorage(
            entityKeyName: entityKeyName,
            from: createContainer(modelName: modelName, bundle: bundle)
        )
    }
    
    public static func create(modelName: String, managedObjectModel: NSManagedObjectModel, entityKeyName: String) -> Promise<CoreDataArrayStorage> {
        convertContainerToStorage(
            entityKeyName: entityKeyName,
            from: createContainer(modelName: modelName, managedObjectModel: managedObjectModel)
        )
    }
    
    private static func convertContainerToStorage(entityKeyName: String, from: Promise<NSPersistentContainer>) -> Promise<CoreDataArrayStorage> {
        
        let objectKeyID = String(describing: Item.self)
        
        return from.then(on: .global()) { container in
            CoreDataContextManager.shared.locker.lock()
            if let arrayStorage = CoreDataContextManager.shared.storages[objectKeyID],
               let storage = arrayStorage as? CoreDataArrayStorage<Item> {
                return storage
            }

            let storage = CoreDataArrayStorage<Item>(entityKeyName: entityKeyName, container: container)
            CoreDataContextManager.shared.storages[objectKeyID] = storage
            return storage
        }.finally {
            CoreDataContextManager.shared.locker.unlock()
        }
    }
    
    private static func createContainer(modelName: String) -> (NSManagedObjectModel) -> Promise<NSPersistentContainer> {
        return { managedObjectModel in
            CoreDataContextManager.shared.locker.lock()
            
            let targetContainer: NSPersistentContainer
            if let container = CoreDataContextManager.shared.loadedContainer {
                targetContainer = container
            } else {
                targetContainer = NSPersistentContainer(
                    name: modelName,
                    managedObjectModel: managedObjectModel
                )
            }
            
            return loadContext(container: targetContainer)
                .then {
                    CoreDataContextManager.shared.loadedContainer = $0
                    return $0
                }.finally {
                    CoreDataContextManager.shared.locker.unlock()
                }
        }
    }
    
    private class func createContainer(modelName: String, bundle: Bundle) -> Promise<NSPersistentContainer> {
        return Promise {
            try fetchManagedObjectModel(modelName: modelName, bundle: bundle)
        }.then { managedObjectModel in
            createContainer(modelName: modelName)(managedObjectModel)
        }
    }
    
    private class func createContainer(modelName: String, managedObjectModel: NSManagedObjectModel) -> Promise<NSPersistentContainer> {
        createContainer(modelName: modelName)(managedObjectModel)
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
    
    public func get(key: Item.Key) -> Promise<Item?> {
        let keyString: CVarArg
        switch key {
        case let key as UUID: keyString = (key as CVarArg)
        default: keyString = String(describing: key)
        }
        
        let predicate = NSPredicate(format: "\(entityKeyName) == %@", keyString)
        
        return Promise {
            self.getAll(predicate: predicate)
                .then { $0.first }
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
    private class func loadContext(container: NSPersistentContainer) -> Promise<NSPersistentContainer> {
        return Promise { resolve, reject in
            if let container = CoreDataContextManager.shared.loadedContainer {
                resolve(container)
            } else {
                container.loadPersistentStores().then { _ in
                    resolve(container)
                }.catch {
                    reject($0)
                }
            }
        }
    }
    
    private class func fetchManagedObjectModel(modelName: String, bundle: Bundle) throws -> NSManagedObjectModel {
        guard
            let url = bundle.url(forResource: modelName, withExtension: "momd"),
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
}
