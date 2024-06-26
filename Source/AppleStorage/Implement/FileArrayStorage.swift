//
//  FileArrayStorage.swift
//  SabyAppleStorage
//
//  Created by MinJae on 9/27/22.
//

import Foundation
import SabyConcurrency
import SabySize
import SabyJSON

private let STORAGE_VERSION = "Version1"

public final class FileArrayStorage<Value: Codable & KeyIdentifiable>: ArrayStorage {
    typealias Context = FileArrayStorageContext
    typealias Item = FileArrayStorageItemVersion1
    
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

extension FileArrayStorage {
    public func add(_ value: Value) -> Promise<Void, Error> {
        execute { context in
            let key = value.key
            
            try context.items.mutate { items in
                items.filter { $0.key != key }
                + [Item(
                    key: key,
                    value: value,
                    date: Date(),
                    byte: try self.encoder.encode(value).count
                )]
            }
            
            print(context.items.capture { $0 })
        }
    }
    
    public func add(_ values: [Value]) -> Promise<Void, Error> {
        execute { context in
            let keys = values.map(\.key)
            
            try context.items.mutate { items in
                items.filter { !keys.contains($0.key) }
                + (try values.map {
                    Item(
                        key: $0.key,
                        value: $0,
                        date: Date(),
                        byte: try self.encoder.encode($0).count
                    )
                })
            }
        }
    }
    
    public func delete(key: UUID) -> Promise<Void, Error> {
        execute { context in
            context.items.mutate { items in
                items.filter { $0.key != key }
            }
        }
    }
    
    public func delete(keys: [UUID]) -> Promise<Void, Error> {
        execute { context in
            context.items.mutate { items in
                items.filter { !keys.contains($0.key) }
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
    
    public func get(limit: Limit) -> Promise<[Value], Error> {
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

    public func get(limit: Limit, order: Order) -> Promise<[Value], Error> {
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
            let compare: (Item<Value>, Item<Value>) -> Bool = (
                order == .oldest ? { $0.date < $1.date } : { $0.date >= $1.date }
            )

            return items.sorted(by: compare).map { $0.value }
        }
    }

    public func save() -> Promise<Void, Error> {
        execute { context in
            let items = context.items.capture { $0 }
            let data = try self.encoder.encode(items)
            
            self.fileLock.lock()
            try data.write(to: context.url)
            self.fileLock.unlock()
        }
    }
}

extension FileArrayStorage {
    public func count() -> Promise<Int, Error> {
        execute { context in
            return context.items.capture { $0.count }
        }
    }
    
    public func size() -> Promise<Volume, Error> {
        execute { context in
            return context.items.capture {
                Volume.byte(Double($0.reduce(0) { result, item in result + item.byte }))
            }
        }
    }
}

extension FileArrayStorage {
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

struct FileArrayStorageContext<Value: Codable> {
    let url: URL
    let items: Atomic<[FileArrayStorageItemVersion1<Value>]>
    
    private init(
        url: URL,
        items: Atomic<[FileArrayStorageItemVersion1<Value>]>
    ) {
        self.url = url
        self.items = items
    }
    
    static func load(
        directoryURL: URL,
        storageName: String,
        migration: @escaping () -> Promise<Void, Error>
    ) -> Promise<FileArrayStorageContext, Error> {
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
                return FileArrayStorageContext(
                    url: url,
                    items: Atomic([])
                )
            }
            
            guard
                let data = try? Data(contentsOf: url),
                let items = try? decoder.decode(
                    [FileArrayStorageItemVersion1<Value>].self,
                    from: data
                )
            else {
                return FileArrayStorageContext(
                    url: url,
                    items: Atomic([])
                )
            }
            
            return FileArrayStorageContext(
                url: url,
                items: Atomic(items)
            )
        }
    }
}

public enum FileArrayStorageError: Error {
    case libraryDirectoryNotFound
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
struct FileArrayStorageItemVersion1<Value: Codable>: Codable {
    let key: UUID
    let value: Value
    let date: Date
    let byte: Int
}
