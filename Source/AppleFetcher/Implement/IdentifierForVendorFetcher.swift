//
//  IdentifierForVendorFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/25.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

public final class IdentifierForVendorFetcher: Fetcher {
    public typealias Value = IdentifierForVendor
    
    public init() {}

    public func fetch() -> IdentifierForVendor {
        IdentifierForVendor(
            identifier: fetchIdentifier()
        )
    }
}

public struct IdentifierForVendor {
    public let identifier: String?
}

extension IdentifierForVendorFetcher {
    private func fetchIdentifier() -> String? {
        UIDevice.current.identifierForVendor?.uuidString
    }
}

#endif
