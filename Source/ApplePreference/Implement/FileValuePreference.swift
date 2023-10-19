//
//  FileValuePreference.swift
//  SabyApplePreference
//
//  Created by WOF on 2023/10/12.
//

import Foundation
import SabySafe
import SabyConcurrency

public final class FileValuePreference<Value: Codable>: ValuePreference {
    typealias Context = FileValuePreferenceContext
    
    let fileLock = Lock()
    
    let contextLoad: () throws -> Context<Value>
    let context: Atomic<Context<Value>?>
    
    let encoder = JSONEncoder()

    public init(directoryURL: URL, fileName: String, migration: @escaping () throws -> Void) {
        self.contextLoad = {
            try Context.load(
                directoryURL: directoryURL,
                fileName: fileName,
                migration: migration
            )
        }
        self.context = Atomic(try? contextLoad())
    }
}

extension FileValuePreference {
    public func set(_ value: Value) throws -> Void {
        try execute { context in
            _ = context.value.mutate { _ in
                value
            }
        }
    }
    
    public func clear() throws -> Void {
        try execute { context in
            _ = context.value.mutate { _ in
                nil
            }
        }
    }

    public func get() throws -> Value? {
        try execute { context in
            context.value.capture { $0 }
        }
    }

    public func save() throws -> Void {
        try execute { context in
            let values = context.value.capture { $0 }
            let data = try self.encoder.encode(values)
            
            self.fileLock.lock()
            try data.write(to: context.url)
            self.fileLock.unlock()
        }
    }
}

extension FileValuePreference {
    fileprivate func execute<Result>(
        block: (Context<Value>) throws -> Result
    ) throws -> Result {
        let current = try context.capture { $0 } ?? contextLoad()
        context.mutate { _ in current }
        
        return try block(current)
    }
}

struct FileValuePreferenceContext<Value: Codable> {
    let url: URL
    let value: Atomic<Value?>
    
    private init(url: URL, value: Atomic<Value?>) {
        self.url = url
        self.value = value
    }
    
    static func load(
        directoryURL: URL,
        fileName: String,
        migration: () throws -> Void
    ) throws -> FileValuePreferenceContext {
        try migration()
        
        let decoder = JSONDecoder()
        let fileManager = FileManager.default
        
        guard directoryURL.isFileURL else {
            throw PreferenceError.directoryURLIsNotFileURL
        }
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        let url = directoryURL.appendingPathComponent(fileName)
        if !fileManager.fileExists(atPath: url.path) {
            return FileValuePreferenceContext(
                url: url,
                value: Atomic(nil)
            )
        }
        
        guard
            let data = try? Data(contentsOf: url),
            let value = try? decoder.decode(
                Value?.self,
                from: data
            )
        else {
            return FileValuePreferenceContext(
                url: url,
                value: Atomic(nil)
            )
        }
        
        return FileValuePreferenceContext(
            url: url,
            value: Atomic(value)
        )
    }
}
