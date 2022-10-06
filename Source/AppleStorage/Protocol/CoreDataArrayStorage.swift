//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import SabyConcurrency
import CoreData

public protocol ManagedObjectUpdater {
    func update(_ mock: Self)
}

// MARK: CoreDataArrayStorage
public final class CoreDataArrayStorage<Item>  where
    Item: (
        KeyIdentifiable
        & NSManagedObject
        & ManagedObjectUpdater
    )
{
    private let container: NSPersistentContainer
    private var hasChanges: Bool { container.viewContext.hasChanges }
    
    public let mockContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    public init?(bundle: Bundle, modelNamed: String) {
        guard
            let url = bundle.url(forResource: modelNamed, withExtension: "momd"),
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
        guard let item: Item = Item.creator()(container.viewContext) else { return }
        item.update(value)
    }
    
    public func delete(_ value: Item) {
        container.viewContext.delete(value)
    }
    
    public func get(key: Item.Key) -> Item? {
        getAll().first { $0.key == key }
    }
    
    public func get(limit: GetLimit) -> [Item] {
        switch limit {
        case .unlimited:
            return getAll()
        case .count(let uInt):
            return getAll(limit: Int(uInt % .max))
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
        let request = fetchRequest(for: String(describing: Item.self))
        try container.viewContext.execute(NSBatchDeleteRequest(fetchRequest: request))
    }
}

extension CoreDataArrayStorage {
    private func fetchRequest(for name: String, limit: Int? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let result = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        if let limit = limit { result.fetchLimit = limit }
        return result
    }
    
    private func getAll(limit: Int? = nil) -> [Item] {
        let request = fetchRequest(for: String(describing: Item.self), limit: limit)
        let items = try? container.viewContext.fetch(request) as? [Item]
        return items ?? []
    }
}

// MARK: - NSManagedObject
fileprivate extension NSManagedObject {
    static func creator<O>() -> (NSManagedObjectContext) -> O? {
        {
            let name = String(describing: self)
            let description = NSEntityDescription.entity(forEntityName: name, in: $0)!
            return self.init(entity: description, insertInto: $0) as? O
        }
    }
}
