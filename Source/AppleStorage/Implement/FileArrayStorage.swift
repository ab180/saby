//
//  FileArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import Foundation
import SabyConcurrency

public final class FileArrayStorage<Value: Codable>: ArrayStorage {
    typealias Context = FileArrayStorageContext
    typealias Item = FileArrayStorageItem
    
    let directoryName: String
    let fileName: String
    let fileLock = Lock()
    
    let contextPromise: Atomic<Promise<Context<Value>, Error>>
    
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

extension FileArrayStorage {
    public func add(_ value: Value) -> Promise<UUID, Error> {
        execute { context in
            let key = UUID()
            
            context.items.mutate { items in
                items.filter { $0.key != key }
                + [Item(key: key, value: value)]
            }

            return key
        }
    }
    
    public func delete(key: UUID) -> Promise<Void, Error> {
        execute { context in
            context.items.mutate { items in
                items.filter { $0.key != key }
            }
        }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { context in
            context.items.mutate { _ in
                []
            }
        }
    }

    public func get(key: UUID) -> Promise<Value?, Error> {
        execute { context in
            let item = context.items.capture { items in
                return items.first { $0.key == key }
            }
            
            return item?.value
        }
    }

    public func get(limit: GetLimit) -> Promise<[Value], Error> {
        execute { context in
            let items = context.items.capture { items in
                switch limit {
                case .unlimited:
                    return items
                case .count(let limit):
                    let limit = min(items.count, limit)
                    return Array(items[0 ..< limit])
                }
            }

            return items.map { $0.value }
        }
    }

    public func save() -> Promise<Void, Error> {
        execute { context in
            let items = context.items.capture { $0 }
            let data = try self.encoder.encode(items)
            
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

extension FileArrayStorage {
    fileprivate func execute<Result>(
        block: @escaping (Context<Value>) throws -> Result
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

struct FileArrayStorageContext<Value: Codable> {
    let url: URL
    let items: Atomic<[FileArrayStorageItem<Value>]>
    
    private init(url: URL, items: Atomic<[FileArrayStorageItem<Value>]>) {
        self.url = url
        self.items = items
    }
    
    static func load(
        directoryName: String,
        fileName: String,
        decoder: PropertyListDecoder,
        fileManager: FileManager
    ) -> Promise<FileArrayStorageContext, Error> {
        Promise { resolve, reject in
            guard
                let libraryDirectoryURL = FileManager.default.urls(
                    for: .libraryDirectory,
                    in: .userDomainMask
                ).first
            else {
                reject(FileArrayStorageError.libraryDirectoryNotFound)
                return
            }
            
            let url = libraryDirectoryURL
                .appendingPathComponent(directoryName)
                .appendingPathComponent(fileName)
            if !fileManager.fileExists(atPath: url.path) {
                resolve(FileArrayStorageContext(
                    url: url,
                    items: Atomic([])
                ))
                return
            }
            
            guard
                let data = try? Data(contentsOf: url),
                let items = try? decoder.decode(
                    [FileArrayStorageItem<Value>].self,
                    from: data
                )
            else {
                resolve(FileArrayStorageContext(
                    url: url,
                    items: Atomic([])
                ))
                return
            }
            
            resolve(FileArrayStorageContext(
                url: url,
                items: Atomic(items)
            ))
        }
    }
}

public enum FileArrayStorageError: Error {
    case libraryDirectoryNotFound
}

struct FileArrayStorageItem<Value: Codable>: Codable {
    let key: UUID
    let value: Value
}
