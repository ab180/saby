//
//  FileDictionaryStorage.swift
//  SabyAppleStorage
//
//  Created by mjgu on 2023/01/19.
//

import Foundation
import SabyConcurrency

public final class FileDictionaryStorage<
    Key: Hashable & Codable,
    Value: Codable
>: DictionaryStorage {
    typealias Context = FileDictionaryStorageContext
    
    let directoryName: String
    let fileName: String
    let fileLock = Lock()
    
    let contextPromise: Atomic<Promise<Context<Key, Value>, Error>>
    
    let encoder = PropertyListEncoder()
    let decoder = PropertyListDecoder()
    let fileManager = FileManager.default

    public init(directoryName: String, fileName: String) {
        self.directoryName = directoryName
        self.fileName = fileName
        
        self.contextPromise = Atomic(Context.load(
            directoryName: directoryName,
            fileName: fileName,
            decoder: decoder,
            fileManager: fileManager
        ))
    }
}

extension FileDictionaryStorage {
    public func set(key: Key, value: Value) -> Promise<Void, Error> {
        execute { context in
            context.values.mutate { values in
                var values = values
                values[key] = value
                return values
            }
        }
    }
    
    public func delete(key: Key) -> Promise<Void, Error> {
        execute { context in
            context.values.mutate { values in
                var values = values
                values[key] = nil
                return values
            }
        }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { context in
            context.values.mutate { _ in
                [:]
            }
        }
    }

    public func get(key: Key) -> Promise<Value?, Error> {
        execute { context in
            context.values.capture { values in
                values[key]
            }
        }
    }

    public func save() -> Promise<Void, Error> {
        execute { context in
            let values = context.values.capture { $0 }
            let data = try self.encoder.encode(values)
            
            let directoryURL = context.url.deletingLastPathComponent()
            if !self.fileManager.fileExists(atPath: directoryURL.path) {
                try self.fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true
                )
            }
            
            self.fileLock.lock()
            try data.write(to: context.url)
            self.fileLock.unlock()
        }
    }
}

extension FileDictionaryStorage {
    fileprivate func execute<Result>(
        block: @escaping (Context<Key, Value>) throws -> Result
    ) -> Promise<Result, Error> {
        let loadPromiseCapture = self.contextPromise.mutate {
            let capture = !$0.isRejected ? $0 : Context.load(
                directoryName: self.directoryName,
                fileName: self.fileName,
                decoder: self.decoder,
                fileManager: self.fileManager
            )
            return capture
        }
        
        return loadPromiseCapture.then { context in
            Promise<Result, Error> { resolve, reject in
                do {
                    resolve(try block(context))
                }
                catch {
                    reject(error)
                }
            }
        }
    }
}

struct FileDictionaryStorageContext<Key: Hashable & Codable, Value: Codable> {
    let url: URL
    let values: Atomic<[Key: Value]>
    
    private init(url: URL, values: Atomic<[Key: Value]>) {
        self.url = url
        self.values = values
    }
    
    static func load(
        directoryName: String,
        fileName: String,
        decoder: PropertyListDecoder,
        fileManager: FileManager
    ) -> Promise<FileDictionaryStorageContext, Error> {
        Promise { resolve, reject in
            guard
                let libraryDirectoryURL = FileManager.default.urls(
                    for: .libraryDirectory,
                    in: .userDomainMask
                ).first
            else {
                reject(FileDictionaryStorageError.libraryDirectoryNotFound)
                return
            }
            
            let url = libraryDirectoryURL
                .appendingPathComponent(directoryName)
                .appendingPathComponent(fileName)
            if !fileManager.fileExists(atPath: url.path) {
                resolve(FileDictionaryStorageContext(
                    url: url,
                    values: Atomic([:])
                ))
                return
            }
            
            guard
                let data = try? Data(contentsOf: url),
                let values = try? decoder.decode(
                    [Key: Value].self,
                    from: data
                )
            else {
                resolve(FileDictionaryStorageContext(
                    url: url,
                    values: Atomic([:])
                ))
                return
            }
            
            resolve(FileDictionaryStorageContext(
                url: url,
                values: Atomic(values)
            ))
        }
    }
}

public enum FileDictionaryStorageError: Error {
    case libraryDirectoryNotFound
}
