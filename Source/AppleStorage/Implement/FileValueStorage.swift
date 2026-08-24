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

public final class FileValueStorage<Value: Codable & Sendable>: ValueStorage {
    typealias Context = FileValueStorageContext
    
    let contextPromise: Promise<Context<Value>, Error>
    let tasks = PromiseTaskScope()

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

extension FileValueStorage {
    public func set(_ value: Value) -> Promise<Void, Error> {
        execute { await $0.set(value) }
    }
    
    public func clear() -> Promise<Void, Error> {
        execute { await $0.clear() }
    }

    public func get() -> Promise<Value?, Error> {
        execute { await $0.get() }
    }

    public func save() -> Promise<Void, Error> {
        execute { try await $0.save() }
    }
}

extension FileValueStorage {
    fileprivate func execute<Result: Sendable>(
        block: @escaping @Sendable (Context<Value>) async throws -> Result
    ) -> Promise<Result, Error> {
        let contextPromise = self.contextPromise

        return tasks.promise {
            let context = try await contextPromise.value(
                cancelOnTaskCancellation: false
            )
            return try await block(context)
        }
    }
}

actor FileValueStorageContext<Value: Codable & Sendable> {
    let url: URL
    var value: FileValueStorageItemVersion1<Value>?
    
    private init(url: URL, value: FileValueStorageItemVersion1<Value>?) {
        self.url = url
        self.value = value
    }

    func set(_ value: Value) {
        self.value = value
    }

    func clear() {
        value = nil
    }

    func get() -> Value? {
        value
    }

    func save() throws {
        let data = try JSONEncoder.acceptingNonConfirmingFloat().encode(value)
        try data.write(to: url)
    }
    
    static func load(
        directoryURL: URL,
        storageName: String,
        migration: @Sendable () -> Promise<Void, Error>
    ) -> Promise<FileValueStorageContext, Error> {
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
                return FileValueStorageContext(
                    url: url,
                    value: nil
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
                    value: nil
                )
            }
            
            return FileValueStorageContext(
                url: url,
                value: value
            )
        }
    }
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
typealias FileValueStorageItemVersion1<Value: Codable & Sendable> = Value
