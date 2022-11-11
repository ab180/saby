//
//  FileArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import Foundation
import SabyConcurrency
import SabySafe

// MARK: FileArrayStorage
public final class FileArrayStorage<Item> where
    Item: (
        KeyIdentifiable
        & Codable
    )
{
    private let locker = Lock()
    private let directoryName: String
    private lazy var cachedItems: Atomic<[Item]> = Atomic((try? getAll()) ?? [])
    
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
    
    public init(directoryName: String = "saby.storage") {
        self.directoryName = directoryName
    }
}


extension FileArrayStorage: ArrayStorage {
    public typealias Value = Item
    
    public func push(_ value: Item) {
        locker.lock()
        defer { locker.unlock() }
        
        cachedItems.mutate({ $0 + [value] })
    }
    
    public func delete(_ value: Item) {
        locker.lock()
        defer { locker.unlock() }
        
        cachedItems = Atomic(cachedItems.capture.filter { $0.key != value.key })
    }
    
    public func get(key: Item.Key) -> Promise<Item> {
        let item = cachedItems.capture.first { $0.key == key }
        return Promise {
            try item ?? throwing()
        }
    }
    
    public func get(limit: GetLimit) -> Promise<[Item]> {
        let capturedItems = cachedItems.capture
        
        switch limit {
        case .unlimited:
            return Promise { capturedItems }
        case .count(let limit):
            let min = Int(min(UInt(capturedItems.count), limit))
            return Promise { Array(capturedItems[0 ..< min]) }
        }
    }
    
    public func save() throws -> Promise<Void> {
        locker.lock()
        
        return Promise {
            let data = try PropertyListEncoder().encode(self.cachedItems.capture)
            guard let filePath = self.filePath else { throw URLError(.badURL) }
            try data.write(to: filePath)
            
            self.locker.unlock()
            return
        }
        
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
    
    func removeAll() {
        let manager = FileManager.default
        let urls = manager.urls(for: .libraryDirectory, in: .userDomainMask)
        guard false == urls.isEmpty else { return }
        
        let result = urls[0].appendingPathComponent(directoryName)
        try? manager.removeItem(at: result)
        
        let fetchedItems = (try? getAll()) ?? []
        cachedItems = Atomic(fetchedItems)
    }
}
