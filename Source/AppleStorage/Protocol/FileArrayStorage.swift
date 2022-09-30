//
//  FileArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import Foundation

public class FileArrayStorage<Item>: ArrayStorage where Item: KeyIdentifiable & Codable {
    public typealias Value = Item
    
    public func push(_ value: Item) {
        try? write(item: value)(pushConverter)
    }
    
    public func delete(_ value: Item) {
        try? write(item: value)(deleteConverter)
    }
    
    public func get(key: Item.Key) -> Item? {
        getAll().first { $0.key == key }
    }
    
    public func get(limit: GetLimit) -> [Item] {
        let items = getAll()
        
        switch limit {
        case .unlimited:
            return items
        case .count(let uInt):
            let maxCount: Int
            (uInt >= items.count) ? (maxCount = items.count) : (maxCount = Int(uInt))
            return Array(items[0..<maxCount])
        }
    }
    
    // MARK: - Inner Methods
    private var filePath: URL? {
        let manager = FileManager.default
        let urls = manager.urls(for: .libraryDirectory, in: .userDomainMask)
        guard false == urls.isEmpty else { return nil }
        
        let directoryName = "saby.storage"
        var result = urls[0].appendingPathComponent(directoryName)
        if false == manager.fileExists(atPath: result.path) {
            try? manager.createDirectory(at: result, withIntermediateDirectories: true)
        }
        
        result = result.appendingPathComponent(String(describing: Item.self))
        return result
    }
    
    private func getAll() -> [Item] {
        guard
            let filePath = self.filePath,
            let data = try? Data(contentsOf: filePath),
            let decodedData = try? PropertyListDecoder().decode([Item].self, from: data)
        else { return [] }
        
        return decodedData
    }
    
    private typealias DataConverter<O> = (O) throws -> Data
    private func write(item: Item) -> (DataConverter<Item>) throws -> Void {
        return { handler in
            guard let filePath = self.filePath else { throw URLError(.badURL) }
            try handler(item).write(to: filePath)
        }
    }
    
    private func pushConverter(_ value: Item) throws -> Data {
        var items = getAll()
        items.append(value)
        return try PropertyListEncoder().encode(items)
    }
    
    private func deleteConverter(_ value: Item) throws -> Data {
        let items = getAll().filter { $0.key != value.key }
        return try PropertyListEncoder().encode(items)
    }
}
