//
//  Preference.swift
//  SabyApplePreference
//
//  Created by WOF on 2023/10/12.
//

import Foundation

public protocol Preference {
    /// ``init(directoryURL:fileName:migration:)``
    /// execute migration and then create or load preference from
    /// `{Directory url}/{File name}` path.
    init(directoryURL: URL, fileName: String, migration: @escaping () throws -> Void)
}

extension Preference {
    /// ``init(directoryName:fileName:)`` create or load storage from
    /// `{Directory url}/{File name}` path.
    public init(directoryURL: URL, fileName: String) {
        self.init(directoryURL: directoryURL, fileName: fileName, migration: {})
    }
}

public enum PreferenceError: Error {
    case directoryURLIsNotFileURL
}
