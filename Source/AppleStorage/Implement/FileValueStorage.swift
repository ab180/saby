//
//  FileValueStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2023/02/23.
//

import Foundation
import SabyConcurrency
import SabyJSON

private let STORAGE_VERSION = "Version1"

public final class FileValueStorage<Value: Codable>: ValueStorage {
    typealias Context = FileValueStorageContext
    
    let fileLock = Lock()
    
    let contextLoad: () -> Promise<Context<Value>, Error>
    let contextPromise: Atomic<Promise<Context<Value>, Error>>
    
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

extension FileValueStorage {
    public func set(_ value: Value) -> Promise<Void, Error> {
        execute { context in
            context.value.mutate { _ in
                value
            }
        }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { context in
            context.value.mutate { _ in
                nil
            }
        }
    }

    public func get() -> Promise<Value?, Error> {
        execute { context in
            context.value.capture { $0 }
        }
    }

    public func save() -> Promise<Void, Error> {
        execute { context in
            let values = context.value.capture { $0 }
            let data = try self.encoder.encode(values)
            
            self.fileLock.lock()
            try data.write(to: context.url)
            self.fileLock.unlock()
        }
    }
}

extension FileValueStorage {
    fileprivate func execute<Result>(
        block: @escaping (Context<Value>) throws -> Result
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

struct FileValueStorageContext<Value: Codable> {
    let url: URL
    let value: Atomic<FileValueStorageItemVersion1<Value>?>
    
    private init(url: URL, value: Atomic<FileValueStorageItemVersion1<Value>?>) {
        self.url = url
        self.value = value
    }
    
    static func load(
        directoryURL: URL,
        storageName: String,
        migration: @escaping () -> Promise<Void, Error>
    ) -> Promise<FileValueStorageContext, Error> {
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
            
            let url = directoryURL.appendingPathComponent("\(storageName)_\(STORAGE_VERSION)")
            if !fileManager.fileExists(atPath: url.path) {
                return FileValueStorageContext(
                    url: url,
                    value: Atomic(nil)
                )
            }
            
            guard
                let data = try? Data(contentsOf: url),
                let value = try? decoder.decode(
                    FileValueStorageItemVersion1<Value>?.self,
                    from: data
                )
            else {
                return FileValueStorageContext(
                    url: url,
                    value: Atomic(nil)
                )
            }
            
            return FileValueStorageContext(
                url: url,
                value: Atomic(value)
            )
        }
    }
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
typealias FileValueStorageItemVersion1<Value: Codable> = Value
