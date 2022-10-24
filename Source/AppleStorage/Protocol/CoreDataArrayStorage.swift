//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import SabyConcurrency
import CoreData

public protocol ManagedObjectUpdater {
    func updateData(_ mock: Self)
}

// MARK: CoreDataArrayStorage
public final class CoreDataArrayStorage<Item> where
    Item: (
        KeyIdentifiable
        & NSManagedObject
        & ManagedObjectUpdater
    )
{
    private var container: NSPersistentContainer?
    private var context: NSManagedObjectContext
    private var keyEntityNamed: String?
    
    public let mockContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    private init() {
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }
    
    public class func create(bundle: Bundle, modelNamed: String, keyEntityNamed: String) -> Promise<CoreDataArrayStorage> {
        return Promise<CoreDataArrayStorage> { resolve, reject in
            let storage = CoreDataArrayStorage()
            storage.keyEntityNamed = keyEntityNamed
            
            guard
                false == keyEntityNamed.isEmpty,
                let url = bundle.url(forResource: modelNamed, withExtension: "momd"),
                FileManager.default.fileExists(atPath: url.path),
                let managedObjectModel = NSManagedObjectModel(contentsOf: url)
            else {
                reject(URLError(.badURL))
                return
            }
            
            storage.container = NSPersistentContainer(
                name: modelNamed, managedObjectModel: managedObjectModel
            )
            
            guard let container = storage.container else {
                reject(URLError(.fileDoesNotExist))
                return
            }
            
            container.loadPersistentStores { _, error in
                if let error = error {
                    reject(error)
                    return
                }
                
                if (false) {
                    storage.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    storage.context.automaticallyMergesChangesFromParent = true
                } else if let context = storage.container?.viewContext {
                    storage.context = context
                }
                
                resolve(storage)
            }
        }
    }
}

extension CoreDataArrayStorage: ArrayStorage {
    public typealias Value = Item
    
    public func push(_ value: Item) {
        guard let item: Item = Item.creator(context: self.context) else { return }
        item.updateData(value)
    }
    
    public func delete(_ value: Item) {
        self.context.delete(value)
    }
    
    public func get(key: Item.Key) -> Item? {
        let keyString: CVarArg
        switch key {
        case let key as UUID: keyString = (key as CVarArg)
        default: keyString = String(describing: key)
        }
        
        let predicate = NSPredicate(format: "\(keyEntityNamed ?? "") == %@", keyString)
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
    
    public func save() -> Promise<Void> {
        return Promise<Void> { resolve, reject in
            try self.context.save()
            resolve(())
        }
    }
}

extension CoreDataArrayStorage {
    func removeAll() throws {
        let request = fetchRequest()
        try self.context.execute(NSBatchDeleteRequest(fetchRequest: request))
        
        
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
        let items = try? self.context.fetch(request) as? [Item]
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
