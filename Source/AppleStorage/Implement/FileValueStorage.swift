//
//  FileValueStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2023/02/23.
//

import Foundation
import SabySafe
import SabyConcurrency

public final class FileValueStorage<Value: Codable> {
    private let lock = Lock()
    private let directoryName: String
    private let fileName: String
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private lazy var cachedItem: Atomic<Value?> = Atomic(fetch())
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

    public init(directoryName: String, fileName: String) {
        self.directoryName = directoryName
        self.fileName = fileName
    }
}

extension FileValueStorage: ValueStorage {
    public func set(_ value: Value) {
        cachedItem.mutate { _ in value }
    }
    
    public func delete() {
        cachedItem.mutate { _ in nil }
    }
    
    public func get() -> Promise<Value?, Error> {
        return .resolved(cachedItem.capture)
    }
    
    public func save() -> Promise<Void, Error> {
        Promise { () -> Void in
            let data = try self.encoder.encode(self.cachedItem.capture)
            guard let filePath = self.fileURL else { throw URLError(.badURL) }
            
            self.lock.lock()
            defer { self.lock.unlock() }
            
            if
                let directoryURL = self.directoryURL,
                false == FileManager.default.fileExists(atPath: directoryURL.path)
            {
                try FileManager.default.createDirectory(
                    at: directoryURL, withIntermediateDirectories: true
                )
            }
            
            try data.write(to: filePath)
        }
    }
}

extension FileValueStorage {
    fileprivate func fetch() -> Value? {
        guard
            let directoryURL = self.directoryURL,
            let filePath = self.fileURL,
            FileManager.default.fileExists(atPath: directoryURL.path),
            FileManager.default.fileExists(atPath: filePath.path),
            let data = try? Data(contentsOf: filePath),
            let dictionary = try? self.decoder.decode(Value?.self, from: data)
        else {
            return nil
        }
        
        return dictionary
    }
}
