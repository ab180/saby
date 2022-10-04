//
//  CoreDataArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import Foundation
import CoreData

public protocol ManagedObjectUpdater {
    func update(_ mock: Self)
}

public class CoreDataArrayStorage<Item>: ArrayStorage
where Item: KeyIdentifiable & NSManagedObject & ManagedObjectUpdater {
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
    
    public func save() throws {
        try container.viewContext.save()
    }
    
    public func rollback() {
        container.viewContext.rollback()
    }
    
    public func removeAll() throws {
        let request = fetchRequest(for: String(describing: Item.self))
        try container.viewContext.execute(NSBatchDeleteRequest(fetchRequest: request))
    }
    
    // MARK: -
    public let mockContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    private let container: NSPersistentContainer
    
    private var hasChanges: Bool { container.viewContext.hasChanges }
    
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
    
    private func fetchRequest(for name: String, limit: Int? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let result = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        if let limit = limit { result.fetchLimit = limit }
        return result
    }
    
    func getAll(limit: Int? = nil) -> [Item] {
        let request = fetchRequest(for: String(describing: Item.self), limit: limit)
        let items = try? container.viewContext.fetch(request) as? [Item]
        return items ?? []
    }
}

// MARK: - Extensions
fileprivate extension NSManagedObject {
    static func creator<O>() -> (NSManagedObjectContext) -> O? {
        {
            let name = String(describing: self)
            let description = NSEntityDescription.entity(forEntityName: name, in: $0)!
            return self.init(entity: description, insertInto: $0) as? O
        }
    }
}