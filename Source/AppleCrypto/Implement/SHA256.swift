//
//  SHA256.swift
//  SabyAppleCrypto
//
//  Created by WOF on 2023/02/17.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation
import CommonCrypto

public enum SHA256: Hash {
    public static func hash(message: String) -> String {
        var result = Array<UInt8>(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256(
            message,
            CC_LONG(message.utf8.count),
            &result
        )
        
        return result.reduce("") { $0 + String(format: "%02x", $1) }
    }
}

#endif
