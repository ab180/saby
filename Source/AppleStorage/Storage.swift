//
//  Storage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2023/07/12.
//

import Foundation
import SabyConcurrency

public protocol Storage {
    /// ``init(directoryName:fileName:migrations:)``
    /// execute migrations orderly and then create or load storage from
    /// `{Library directory}/{Directory name}/{File name}` path.
    init(directoryName: String, fileName: String, migrations: [() -> Promise<Void, Error>])
    /// ``init(baseURL:directoryName:fileName:migrations:)``
    /// execute migrations orderly and then create or load storage from
    /// `{Base url}/{Directory name}/{File name}` path.
    init(baseURL: URL, directoryName: String, fileName: String, migrations: [() -> Promise<Void, Error>])
}

extension Storage {
    /// ``init(directoryName:fileName:)`` create or load storage from
    /// `{Library directory}/{Directory name}/{File name}` path.
    init(directoryName: String, fileName: String) {
        self.init(directoryName: directoryName, fileName: fileName, migrations: [])
    }
    /// ``init(baseURL:directoryName:fileName:)`` create or load storage from
    /// `{Base url}/{Directory name}/{File name}` path.
    init(baseURL: URL, directoryName: String, fileName: String) {
        self.init(baseURL: baseURL, directoryName: directoryName, fileName: fileName, migrations: [])
    }
}

public enum StorageError: Error {
    case libraryDirectoryNotFound
    case baseURLIsNotFileURL
    case baseURLIsNotExist
}
