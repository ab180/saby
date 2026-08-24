//
//  FileValuePreference.swift
//  SabyApplePreference
//
//  Created by WOF on 2023/10/12.
//

import Foundation
import SabyJSON

private let STORAGE_VERSION = "Version1"

public actor FileValuePreference<Value: Codable & Sendable>: ValuePreference {
    typealias Context = FileValuePreferenceContext

    private let directoryURL: URL
    private let storageName: String
    private let migration: @Sendable () throws -> Void
    private var context: Context<Value>?

    public init(
        directoryURL: URL,
        storageName: String,
        migration: @escaping @Sendable () throws -> Void
    ) {
        self.directoryURL = directoryURL
        self.storageName = storageName
        self.migration = migration
        self.context = try? Context.load(
            directoryURL: directoryURL,
            storageName: storageName,
            migration: migration
        )
    }
}

extension FileValuePreference {
    public func set(_ value: Value) async throws -> Void {
        try execute { $0.value = value }
    }
    
    public func clear() async throws -> Void {
        try execute { $0.value = nil }
    }

    public func get() async throws -> Value? {
        try execute { $0.value }
    }

    public func save() async throws -> Void {
        try execute { context in
            let data = try JSONEncoder.acceptingNonConfirmingFloat().encode(context.value)
            try data.write(to: context.url)
        }
    }
}

extension FileValuePreference {
    fileprivate func execute<Result>(
        block: (inout Context<Value>) throws -> Result
    ) throws -> Result {
        var context: Context<Value>
        if let current = self.context {
            context = current
        } else {
            context = try Context.load(
                directoryURL: directoryURL,
                storageName: storageName,
                migration: migration
            )
        }

        let result = try block(&context)
        self.context = context
        return result
    }
}

struct FileValuePreferenceContext<Value: Codable & Sendable>: Sendable {
    let url: URL
    var value: FileValuePreferenceItemVersion1<Value>?
    
    private init(url: URL, value: FileValuePreferenceItemVersion1<Value>?) {
        self.url = url
        self.value = value
    }
    
    static func load(
        directoryURL: URL,
        storageName: String,
        migration: @Sendable () throws -> Void
    ) throws -> FileValuePreferenceContext {
        try migration()
        
        let decoder = JSONDecoder.acceptingNonConfirmingFloat()
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

        let url = directoryURL.appendingPathComponent("\(storageName)_\(STORAGE_VERSION)")
        if !fileManager.fileExists(atPath: url.path) {
            return FileValuePreferenceContext(
                url: url,
                value: nil
            )
        }
        
        guard
            let data = try? Data(contentsOf: url),
            let value = try? decoder.decode(
                FileValuePreferenceItemVersion1<Value>?.self,
                from: data
            )
        else {
            return FileValuePreferenceContext(
                url: url,
                value: nil
            )
        }
        
        return FileValuePreferenceContext(
            url: url,
            value: value
        )
    }
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
typealias FileValuePreferenceItemVersion1<Value: Codable & Sendable> = Value
