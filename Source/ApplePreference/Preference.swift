//
//  Preference.swift
//  SabyApplePreference
//
//  Created by WOF on 2023/10/12.
//

import Foundation

public protocol Preference {
    /// ``init(directoryURL:storageName:migration:)``
    /// execute migration and then create or load preference from
    /// `{Directory url}/{Storage name}_{Version name}` path.
    init(directoryURL: URL, storageName: String, migration: @escaping () throws -> Void)
}

extension Preference {
    /// ``init(directoryName:storageName:)`` create or load storage from
    /// `{Directory url}/{Storage name}_{Version name}` path.
    public init(directoryURL: URL, storageName: String) {
        self.init(directoryURL: directoryURL, storageName: storageName, migration: {})
    }
}

public enum PreferenceError: Error {
    case directoryURLIsNotFileURL
}
