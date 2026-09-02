//
//  IdentifierForVendorFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/25.
//

#if (os(iOS) || os(tvOS) || os(visionOS)) && canImport(UIKit)

import Foundation
import UIKit

import SabyConcurrency

public final class IdentifierForVendorFetcher: Fetcher {
    public typealias Value = Promise<IdentifierForVendor, Never>
    
    public init() {}

    public func fetch() -> Promise<IdentifierForVendor, Never> {
        Promise.async {
            await MainActor.run {
                IdentifierForVendor(
                    identifier: UIDevice.current.identifierForVendor?.uuidString
                )
            }
        }
    }
}

public struct IdentifierForVendor: Sendable {
    public let identifier: String?
}

#endif
