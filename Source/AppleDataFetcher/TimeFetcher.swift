//
//  TimeFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation

public final class TimeFetcher: Fetcher {
    typealias Value = Time

    func fetch() -> Time {
        Time(
            millisecondsSince1970: fetchMillisecondsSince1970()
        )
    }
}

public struct Time {
    let millisecondsSince1970: UInt64
}

extension TimeFetcher {
    private func fetchMillisecondsSince1970() -> UInt64 {
        UInt64(Date().timeIntervalSince1970 * 1000)
    }
}

#endif
