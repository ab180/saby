//
//  OSFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/24.
//

#if (os(iOS) || os(tvOS) || os(visionOS)) && canImport(UIKit)

import Foundation
import UIKit

import SabyConcurrency

public final class OSFetcher: Fetcher {
    public typealias Value = Promise<OS, Never>
    
    public init() {}

    public func fetch() -> Promise<OS, Never> {
        Promise.async {
            await MainActor.run {
                let device = UIDevice.current

                return OS(
                    name: device.systemName,
                    version: device.systemVersion
                )
            }
        }
    }
}

public struct OS: Sendable {
    public let name: String
    public let version: String
}

#endif
