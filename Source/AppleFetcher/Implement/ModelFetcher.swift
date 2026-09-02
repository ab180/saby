//
//  ModelFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/23.
//

#if (os(iOS) || os(tvOS) || os(visionOS)) && canImport(UIKit)

import Foundation
import UIKit

import SabyConcurrency

public final class ModelFetcher: Fetcher {
    public typealias Value = Promise<Model, Never>
    
    public init() {}

    public func fetch() -> Promise<Model, Never> {
        Promise.async {
            let name = await MainActor.run {
                UIDevice.current.localizedModel
            }

            return Model(
                name: name,
                identifier: Self.fetchIdentifier()
            )
        }
    }
}

public struct Model: Sendable {
    public let name: String
    public let identifier: String?
}

extension ModelFetcher {
    private static func fetchIdentifier() -> String? {
        var system = utsname()
        uname(&system)
        
        return withUnsafeMutablePointer(to: &system.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0)
            }
        }
    }
}

#endif
