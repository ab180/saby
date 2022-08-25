//
//  IdentifierForVendorFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/25.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

public final class IdentifierForVendorFetcher: Fetcher {
    typealias Value = IdentifierForVendor

    func fetch() -> IdentifierForVendor {
        IdentifierForVendor(
            identifier: fetchIdentifier()
        )
    }
}

public struct IdentifierForVendor {
    let identifier: String?
}

extension IdentifierForVendorFetcher {
    private func fetchIdentifier() -> String? {
        UIDevice.current.identifierForVendor?.uuidString
    }
}

#endif
