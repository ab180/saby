//
//  Storage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2023/07/12.
//

import Foundation
import SabyConcurrency

public protocol Storage {
    /// ``init(directoryURL:fileName:migration:)``
    /// execute migration and then create or load preference from
    /// `{Directory url}/{File name}` path.
    init(directoryURL: URL, fileName: String, migration: @escaping () -> Promise<Void, Error>)
}

extension Storage {
    /// ``init(directoryName:fileName:)`` create or load storage from
    /// `{Directory url}/{File name}` path.
    public init(directoryURL: URL, fileName: String) {
        self.init(directoryURL: directoryURL, fileName: fileName, migration: { .resolved(()) })
    }
}

public enum StorageError: Error {
    case directoryURLIsNotFileURL
}
