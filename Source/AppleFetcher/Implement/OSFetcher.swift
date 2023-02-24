//
//  OSFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

public final class OSFetcher: Fetcher {
    public typealias Value = OS
    
    public init() {}

    public func fetch() -> OS {
        OS(
            name: fetchName(),
            version: fetchVersion()
        )
    }
}

public struct OS {
    public let name: String
    public let version: String
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
