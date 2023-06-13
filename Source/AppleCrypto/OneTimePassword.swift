//
//  OneTimePassword.swift
//  SabyAppleCrypto
//
//  Created by WOF on 2023/06/13.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation
import SabyTime

public protocol OneTimePassword<Hash, Digit> {
    associatedtype Hash: RawRepresentable
    associatedtype Digit: RawRepresentable
    
    static func password(
        timestamp: Timestamp,
        key: String,
        hash: Hash,
        interval: Interval,
        digit: Digit
    ) -> String
}

#endif
