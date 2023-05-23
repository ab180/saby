//
//  FileValueStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2023/02/23.
//

import Foundation
import SabySafe
import SabyConcurrency

public final class FileValueStorage<Value: Codable>: ValueStorage {
    typealias Context = FileValueStorageContext
    
    let directoryName: String
    let fileName: String
    let fileLock = Lock()
    
    let contextPromise: Atomic<Promise<Context<Value>, Error>>
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
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

extension FileValueStorage {
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

struct FileValueStorageContext<Value: Codable> {
    let url: URL
    let value: Atomic<Value?>
    
    private init(url: URL, value: Atomic<Value?>) {
        self.url = url
        self.value = value
    }
    
    static func load(
        directoryName: String,
        fileName: String,
        decoder: JSONDecoder,
        fileManager: FileManager
    ) -> Promise<FileValueStorageContext, Error> {
        Promise { resolve, reject in
            guard
                let libraryDirectoryURL = FileManager.default.urls(
                    for: .libraryDirectory,
                    in: .userDomainMask
                ).first
            else {
                reject(FileValueStorageError.libraryDirectoryNotFound)
                return
            }
            
            let url = libraryDirectoryURL
                .appendingPathComponent(directoryName)
                .appendingPathComponent(fileName)
            if !fileManager.fileExists(atPath: url.path) {
                resolve(FileValueStorageContext(
                    url: url,
                    value: Atomic(nil)
                ))
                return
            }
            
            guard
                let data = try? Data(contentsOf: url),
                let value = try? decoder.decode(
                    Value?.self,
                    from: data
                )
            else {
                resolve(FileValueStorageContext(
                    url: url,
                    value: Atomic(nil)
                ))
                return
            }
            
            resolve(FileValueStorageContext(
                url: url,
                value: Atomic(value)
            ))
        }
    }
}

public enum FileValueStorageError: Error {
    case libraryDirectoryNotFound
}
