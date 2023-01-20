//
//  FileDictionaryStorage.swift
//  
//
//  Created by mjgu on 2023/01/19.
//

import Foundation
import SabySafe
import SabyConcurrency

public final class FileDictionaryStorage<Key, Value>
where Key: Hashable & Codable, Value: Codable
{
    private let locker = Lock()
    private let directoryName: String
    private let fileName: String
    private lazy var cachedItems: Atomic<[Key: Value]> = Atomic(fetchFromFiles())
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

extension FileDictionaryStorage: DictionaryStorage {
    
    public typealias Key = Key
    public typealias Value = Value
    
    public var keys: Dictionary<Key, Value>.Keys {
        cachedItems.capture.keys
    }
    
    public var values: Dictionary<Key, Value>.Values {
        cachedItems.capture.values
    }
    
    public func set(key: Key, value: Value) {
        locker.lock()
        defer { locker.unlock() }
        
        cachedItems.mutate({
            var mutable = $0
            mutable[key] = value
            return mutable
        })
    }
    
    public func delete(key: Key) {
        locker.lock()
        defer { locker.unlock() }
        
        cachedItems.mutate {
            var mutable = $0
            mutable.removeValue(forKey: key)
            return mutable
        }
    }
    
    public func get(key: Key) -> Promise<Value> {
        guard let result = cachedItems.capture[key] else { return .rejected(ThrowingError.defaultError) }
        return .resolved(result)
    }
    
    public func save() -> Promise<Void> {
        return Promise {
            self.locker.lock()
            
            let data = try PropertyListEncoder().encode(self.cachedItems.capture)
            guard let filePath = self.fileURL else { throw URLError(.badURL) }

            if
                let directoryURL = self.directoryURL,
                false == FileManager.default.fileExists(atPath: directoryURL.path) {
                
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

extension FileDictionaryStorage {
    private func fetchFromFiles() -> [Key: Value] {
        guard
            let directoryURL = self.directoryURL,
            let filePath = self.fileURL,
            true == FileManager.default.fileExists(atPath: directoryURL.path),
            true == FileManager.default.fileExists(atPath: filePath.path),
            
            let data = try? Data(contentsOf: filePath),
            let dictionary = try? PropertyListDecoder().decode([Key: Value].self, from: data)
        else { return [:] }
        
        return dictionary
    }
    
    func removeAll() {
        let manager = FileManager.default
        let urls = manager.urls(for: .libraryDirectory, in: .userDomainMask)
        guard false == urls.isEmpty else { return }
        
        let result = urls[0].appendingPathComponent(directoryName)
        try? manager.removeItem(at: result)
        
        let fetchedItems = fetchFromFiles()
        cachedItems = Atomic(fetchedItems)
    }
}
