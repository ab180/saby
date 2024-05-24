//
//  FileDictionaryStorage.swift
//  SabyAppleStorage
//
//  Created by mjgu on 2023/01/19.
//

import Foundation
import SabyConcurrency
import SabyJSON

private let STORAGE_VERSION = "Version1"

public final class FileDictionaryStorage<
    Key: Hashable & Codable,
    Value: Codable
>: DictionaryStorage {
    typealias Context = FileDictionaryStorageContext

    let fileLock = Lock()
    
    let contextLoad: () -> Promise<Context<Key, Value>, Error>
    let contextPromise: Atomic<Promise<Context<Key, Value>, Error>>
    
    let encoder = JSONEncoder.acceptingNonConfirmingFloat()

    public init(directoryURL: URL, storageName: String, migration: @escaping () -> Promise<Void, Error>) {
        self.contextLoad = {
            Context.load(
                directoryURL: directoryURL,
                storageName: storageName,
                migration: migration
            )
        }
        self.contextPromise = Atomic(contextLoad())
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
            let capture = !$0.isRejected ? $0 : contextLoad()
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
    let values: Atomic<FileDictionaryStorageItemVersion1<Key, Value>>
    
    private init(url: URL, values: Atomic<FileDictionaryStorageItemVersion1<Key, Value>>) {
        self.url = url
        self.values = values
    }
    
    static func load(
        directoryURL: URL,
        storageName: String,
        migration: @escaping () -> Promise<Void, Error>
    ) -> Promise<FileDictionaryStorageContext, Error> {
        migration().then {
            let decoder = JSONDecoder.acceptingNonConfirmingFloat()
            let fileManager = FileManager.default
            
            guard directoryURL.isFileURL else {
                throw StorageError.directoryURLIsNotFileURL
            }
            
            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true
                )
            }
            
            let url = directoryURL.appendingPathComponent(storageName).appendingPathExtension(STORAGE_VERSION)
            if !fileManager.fileExists(atPath: url.path) {
                return FileDictionaryStorageContext(
                    url: url,
                    values: Atomic([:])
                )
            }
            
            guard
                let data = try? Data(contentsOf: url),
                let values = try? decoder.decode(
                    FileDictionaryStorageItemVersion1<Key, Value>.self,
                    from: data
                )
            else {
                return FileDictionaryStorageContext(
                    url: url,
                    values: Atomic([:])
                )
            }
            
            return FileDictionaryStorageContext(
                url: url,
                values: Atomic(values)
            )
        }
    }
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
typealias FileDictionaryStorageItemVersion1<Key: Hashable & Codable, Value: Codable> = [Key: Value]
