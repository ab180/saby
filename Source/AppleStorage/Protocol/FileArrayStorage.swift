//
//  FileArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import Foundation
import SabyConcurrency

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
    private lazy var cachedItems: [Item] = (try? getAll()) ?? []
    private var willDeleteItems: Set<Item.Key> = []
    private var filterdItems: [Item] {
        cachedItems.filter {
            false == willDeleteItems.contains($0.key)
        }
    }
    
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
        cachedItems.append(value)
    }
    
    public func delete(_ value: Item) {
        willDeleteItems.insert(value.key)
    }
    
    public func get(key: Item.Key) -> Item? {
        filterdItems.first { $0.key == key }
    }
    
    public func get(limit: GetLimit) -> [Item] {
        let filterdItems = self.filterdItems
        switch limit {
        case .unlimited:
            return filterdItems
        case .count(let uInt):
            let maxCount: Int
            (uInt >= filterdItems.count) ? (maxCount = filterdItems.count) : (maxCount = Int(uInt))
            return Array(filterdItems[0 ..< maxCount])
        }
    }
    
    public func save() -> SabyConcurrency.Promise<Void> {
        return Promise<Void>(on: .main) { resolve, reject in
            let completeBlock = BlockOperation {
                resolve(())
            }
            
            let saveBlock = BlockOperation {
                
                let savedData = self.filterdItems
                
                do {
                    let data = try PropertyListEncoder().encode(savedData)
                    guard let filePath = self.filePath else { throw URLError(.badURL) }
                    try data.write(to: filePath)
                    
                    self.willDeleteItems = []
                    self.cachedItems = (try? self.getAll()) ?? []
                    
                } catch {
                    reject(error)
                }
            }
            
            completeBlock.addDependency(saveBlock)
            self.queue.addOperation(completeBlock)
            self.queue.addOperation(saveBlock)
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
    
    func removeAll() {
        let manager = FileManager.default
        let urls = manager.urls(for: .libraryDirectory, in: .userDomainMask)
        guard false == urls.isEmpty else { return }
        
        let result = urls[0].appendingPathComponent(directoryName)
        try? manager.removeItem(at: result)
        
        cachedItems = (try? getAll()) ?? []
    }
}
