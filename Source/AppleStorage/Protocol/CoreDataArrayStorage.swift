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
    private let container: NSPersistentContainer
    private let keyEntityNamed: String
    
    public let mockContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    public init?(bundle: Bundle, modelNamed: String, keyEntityNamed: String) {
        self.keyEntityNamed = keyEntityNamed
        
        guard
            false == keyEntityNamed.isEmpty,
            let url = bundle.url(forResource: modelNamed, withExtension: "momd"),
            FileManager.default.fileExists(atPath: url.path),
            let managedObjectModel = NSManagedObjectModel(contentsOf: url)
        else { return nil }
        
        self.container = NSPersistentContainer(
            name: modelNamed, managedObjectModel: managedObjectModel
        )
        
        container.loadPersistentStores { _, error in
            guard nil == error else { fatalError() }
        }
    }
}

extension CoreDataArrayStorage: ArrayStorage {
    public typealias Value = Item
    
    public func push(_ value: Item) {
        guard let item: Item = Item.creator(context: container.viewContext) else { return }
        item.updateData(value)
    }
    
    public func delete(_ value: Item) {
        container.viewContext.delete(value)
    }
    
    public func get(key: Item.Key) -> Item? {
        let predicate = NSPredicate(format: "\(keyEntityNamed) == %@", String(describing: key))
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
    
    public func save() -> SabyConcurrency.Promise<Void> {
        return Promise<Void>(on: .main) { resolve, reject in
            try self.container.viewContext.save()
            resolve(())
        }
    }
}

extension CoreDataArrayStorage {
    func removeAll() throws {
        let request = fetchRequest()
        try container.viewContext.execute(NSBatchDeleteRequest(fetchRequest: request))
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
        let items = try? container.viewContext.fetch(request) as? [Item]
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
