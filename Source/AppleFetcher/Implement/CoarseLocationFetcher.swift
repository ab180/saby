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
    
    public init() {
        savePreferredLanguages()
    }

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
        guard
            let language = fetchLanguage(),
            let region = fetchRegion()
        else {
            return Locale.autoupdatingCurrent.identifier
        }
        
        return "\(language)-\(region)"
    }
    
    private func fetchTimezone() -> String {
        TimeZone.autoupdatingCurrent.identifier
    }
}

extension CoarseLocationFetcher {
    private func fetchLanguage() -> String? {
        let preferredLanguage = readPreferredLanguages()
        
        guard let source = preferredLanguage.first else {
            return nil
        }
        
        guard let barIndex = source.firstIndex(of: "-") else {
            return source
        }
        
        return String(source[..<barIndex])
    }
    
    private func fetchRegion() -> String? {
        Locale.autoupdatingCurrent.regionCode
    }
}

extension CoarseLocationFetcher {
    private var url: URL? {
        FileManager.default.urls(
            for: .libraryDirectory,
            in: .userDomainMask
        )
        .first?
        .appendingPathComponent("saby")
        .appendingPathComponent("SabyAppleFetcher_Locale_PreferredLanguages")
    }
    
    private func savePreferredLanguages() {
        guard let url else { return }
        let directoryURL = url.deletingLastPathComponent()
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryURL.absoluteString) {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        
        try? JSONEncoder().encode(Locale.preferredLanguages).write(to: url)
    }
    
    private func readPreferredLanguages() -> [String] {
        guard let url else { return Locale.preferredLanguages }
        
        return (
            (try? JSONDecoder().decode([String].self, from: Data(contentsOf: url)))
            ?? Locale.preferredLanguages
        )
    }
}

#endif
