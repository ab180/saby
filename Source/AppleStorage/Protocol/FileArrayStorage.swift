//
//  FileArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import Foundation

// MARK: FileArrayStorage
public final class FileArrayStorage<Item> where
    Item: (
        KeyIdentifiable
        & Codable
    )
{
    private let queue: OperationQueue = {
        let result = OperationQueue()
        result.maxConcurrentOperationCount = 1
        return result
    }()
    
    private let directoryName: String
    
    public init(directoryName: String = "saby.storage") {
        self.directoryName = directoryName
    }
    
    private var filePath: URL? {
        let manager = FileManager.default
        let urls = manager.urls(for: .libraryDirectory, in: .userDomainMask)
        guard false == urls.isEmpty else { return nil }
        
        var result = urls[0].appendingPathComponent(directoryName)
        if false == manager.fileExists(atPath: result.path) {
            try? manager.createDirectory(at: result, withIntermediateDirectories: true)
        }
        
        result = result.appendingPathComponent(String(describing: Item.self))
        return result
    }
}


extension FileArrayStorage: ArrayStorage {
    public typealias Value = Item
    
    public func push(_ value: Item) {
        queue.addOperation {
            try? self.write(item: value)(self.pushConverter)
        }
    }
    
    public func delete(_ value: Item) {
        queue.addOperation {
            try? self.write(item: value)(self.deleteConverter)
        }
    }
    
    public func get(key: Item.Key) -> Item? {
        (try? getAll())?.first { $0.key == key }
    }
    
    public func get(limit: GetLimit) -> [Item] {
        let items = (try? getAll()) ?? []
        
        switch limit {
        case .unlimited:
            return items
        case .count(let uInt):
            let maxCount: Int
            (uInt >= items.count) ? (maxCount = items.count) : (maxCount = Int(uInt))
            return Array(items[0 ..< maxCount])
        }
    }
}

extension FileArrayStorage {
    func addOperation(_ block: BlockOperation) {
        queue.addOperation(block)
    }
}

extension FileArrayStorage {
    private func getAll() throws -> [Item] {
        guard
            let filePath = self.filePath
        else { throw URLError(.badURL) }
        
        do {
            let data = try Data(contentsOf: filePath)
            return try PropertyListDecoder().decode([Item].self, from: data)
        } catch (let error) {
            let nsError = error as NSError
            if (nsError.domain == NSCocoaErrorDomain) { return [] }
            
            throw error
        }
    }
    
    private typealias DataConverter<O> = (O) throws -> Data
    private func write(item: Item) -> (DataConverter<Item>) throws -> Void {
        return { handler in
            guard let filePath = self.filePath else { throw URLError(.badURL) }
            try handler(item).write(to: filePath)
        }
    }
    
    private func pushConverter(_ value: Item) throws -> Data {
        var items = try getAll()
        items.append(value)
        return try PropertyListEncoder().encode(items)
    }
    
    private func deleteConverter(_ value: Item) throws -> Data {
        let items = try getAll().filter { $0.key != value.key }
        return try PropertyListEncoder().encode(items)
    }
}
