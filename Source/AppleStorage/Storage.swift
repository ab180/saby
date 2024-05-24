//
//  Storage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2023/07/12.
//

import Foundation
import SabyConcurrency

public protocol Storage {
    /// ``init(directoryURL:storageName:migration:)``
    /// execute migration and then create or load preference from
    /// `{Directory url}/{Storage name}/{Version name}` path.
    init(directoryURL: URL, storageName: String, migration: @escaping () -> Promise<Void, Error>)
}

extension Storage {
    /// ``init(directoryName:storageName:)`` create or load storage from
    /// `{Directory url}/{Storage name}/{Version name}` path.
    public init(directoryURL: URL, storageName: String) {
        self.init(directoryURL: directoryURL, storageName: storageName, migration: { .resolved(()) })
    }
}

public enum StorageError: Error {
    case directoryURLIsNotFileURL
}
