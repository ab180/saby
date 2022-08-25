//
//  OSFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

public final class OSFetcher: Fetcher {
    typealias Value = OS
    
    public init() {}

    public func fetch() -> OS {
        OS(
            name: fetchName(),
            version: fetchVersion()
        )
    }
}

public struct OS {
    let name: String
    let version: String
}

extension OSFetcher {
    private func fetchName() -> String {
        UIDevice.current.systemName
    }

    private func fetchVersion() -> String {
        UIDevice.current.systemVersion
    }
}

#endif
