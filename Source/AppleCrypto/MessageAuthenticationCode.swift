//
//  MessageAuthenticationCode.swift
//  SabyAppleCrypto
//
//  Created by WOF on 2023/06/13.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation

public protocol MessageAuthenticationCode<Hash> {
    associatedtype Hash: RawRepresentable
    
    static func code(
        message: String,
        key: String,
        hash: Hash
    ) -> String
}

#endif
