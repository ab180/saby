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
    private let fileName: String
    private lazy var cachedItems: Atomic<[Item]> = Atomic((try? getAll()) ?? [])
    
    private lazy var directoryURL: URL? = {
        let manager = FileManager.default
        let urls = manager.urls(for: .libraryDirectory, in: .userDomainMask)
        guard false == urls.isEmpty else { return nil }
        
        var result = urls[0].appendingPathComponent(directoryName)
        
        return result
    }()
    
    private lazy var fileURL: URL? = {
        guard var directoryPath = directoryURL else { return nil }
        return directoryPath.appendingPathComponent(fileName)
    }()
    
    /// Default initializer.
    ///
    /// - Parameters:
    /// - directoryName: Will saved to `SearchPathDirectory.libraryDirectory`/`directoryName` paths.
    public init(directoryName: String, fileName: String) {
        self.directoryName = directoryName
        self.fileName = fileName
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
    
    public func get(key: Item.Key) -> Promise<Item?> {
        let item = cachedItems.capture.first { $0.key == key }
        return Promise.resolved(item)
    }
    
    public func get(limit: GetLimit) -> Promise<[Item]> {
        let capturedItems = cachedItems.capture
        
        switch limit {
        case .unlimited:
            return Promise.resolved(capturedItems)
        case .count(let limit):
            let min = Int(min(UInt(capturedItems.count), limit))
            return Promise.resolved(Array(capturedItems[0 ..< min]))
        }
    }
    
    public func save() -> Promise<Void> {
        return Promise {
            self.locker.lock()
            
            let data = try PropertyListEncoder().encode(self.cachedItems.capture)
            guard let filePath = self.fileURL else {
                throw URLError(.badURL)
            }
            
            if
                let directoryURL = self.directoryURL,
                false == FileManager.default.fileExists(atPath: directoryURL.path)
            {    
                try FileManager.default.createDirectory(
                    at: directoryURL, withIntermediateDirectories: true
                )
            }
            
            try data.write(to: filePath)
            return
        }.finally {
            self.locker.unlock()
        }
    }
}

extension FileArrayStorage {
    private func getAll() throws -> [Item] {
        guard
            let filePath = self.fileURL
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
