//
//  CoarseLocationFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation

import SabyConcurrency

public final class CoarseLocationFetcher: Fetcher {
    public typealias Value = CoarseLocation
    
    public init() {}

    public func fetch() -> CoarseLocation {
        CoarseLocation(
            locale: fetchLocale(),
            timezone: fetchTimezone()
        )
    }
}

public struct CoarseLocation {
    public let locale: String
    public let timezone: String
}

extension CoarseLocationFetcher {
    private func fetchLocale() -> String {
        (UserDefaults(suiteName: "SabyAppleFetcher")?
            .stringArray(forKey: "AppleLanguages")?
            .first ?? Locale.autoupdatingCurrent.identifier)
    }
    
    private func fetchTimezone() -> String {
        TimeZone.autoupdatingCurrent.identifier
    }
}

#endif
