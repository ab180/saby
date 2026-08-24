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
    Key: Hashable & Codable & Sendable,
    Value: Codable & Sendable
>: DictionaryStorage {
    typealias Context = FileDictionaryStorageContext
    
    let contextPromise: Promise<Context<Key, Value>, Error>

    public init(
        directoryURL: URL,
        storageName: String,
        migration: @escaping @Sendable () -> Promise<Void, Error>
    ) {
        self.contextPromise = Context.load(
            directoryURL: directoryURL,
            storageName: storageName,
            migration: migration
        )
    }
}

extension FileDictionaryStorage {
    public func set(key: Key, value: Value) -> Promise<Void, Error> {
        execute { await $0.set(key: key, value: value) }
    }
    
    public func delete(key: Key) -> Promise<Void, Error> {
        execute { await $0.delete(key: key) }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { await $0.clear() }
    }

    public func get(key: Key) -> Promise<Value?, Error> {
        execute { await $0.value(forKey: key) }
    }
    
    public func get(limit: Limit) -> Promise<[Value], Error> {
        let limit = limit.count
        return execute { await $0.values(limit: limit) }
    }

    public func save() -> Promise<Void, Error> {
        execute { try await $0.save() }
    }
}

extension FileDictionaryStorage {
    fileprivate func execute<Result: Sendable>(
        block: @escaping @Sendable (Context<Key, Value>) async throws -> Result
    ) -> Promise<Result, Error> {
        contextPromise.then { context in
            Promise.async {
                try await block(context)
            }
        }
    }
}

actor FileDictionaryStorageContext<
    Key: Hashable & Codable & Sendable,
    Value: Codable & Sendable
> {
    let url: URL
    var values: FileDictionaryStorageItemVersion1<Key, Value>

    private init(url: URL, values: FileDictionaryStorageItemVersion1<Key, Value>) {
        self.url = url
        self.values = values
    }

    func set(key: Key, value: Value) {
        values[key] = value
    }

    func delete(key: Key) {
        values[key] = nil
    }

    func clear() {
        values.removeAll()
    }

    func value(forKey key: Key) -> Value? {
        values[key]
    }

    func values(limit: Int?) -> [Value] {
        let values = Array(values.values)
        guard let limit else { return values }
        return Array(values.prefix(limit))
    }

    func save() throws {
        let data = try JSONEncoder.acceptingNonConfirmingFloat().encode(values)
        try data.write(to: url)
    }

    static func load(
        directoryURL: URL,
        storageName: String,
        migration: @Sendable () -> Promise<Void, Error>
    ) -> Promise<FileDictionaryStorageContext, Error> {
        return migration().then {
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
                return FileDictionaryStorageContext(
                    url: url,
                    values: [:]
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
                    values: [:]
                )
            }
            
            return FileDictionaryStorageContext(
                url: url,
                values: values
            )
        }
    }
}

private extension Limit {
    var count: Int? {
        guard case .count(let count) = self else { return nil }
        return count
    }
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
typealias FileDictionaryStorageItemVersion1<Key: Hashable & Codable & Sendable, Value: Codable & Sendable> = [Key: Value]
