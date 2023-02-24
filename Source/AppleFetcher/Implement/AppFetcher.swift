//
//  AppFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation

public final class AppFetcher: Fetcher {
    public typealias Value = App
    
    public init() {}

    public func fetch() -> App {
        App(
            identifier: fetchIdentifier(),
            name: fetchName(),
            version: fetchVersion()
        )
    }
}

public struct App {
    public let identifier: String?
    public let name: String?
    public let version: String?
}

extension AppFetcher {
    private func fetchIdentifier() -> String? {
        Bundle.main.bundleIdentifier
    }
    
    private func fetchName() -> String? {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
    }

    private func fetchVersion() -> String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

#endif
