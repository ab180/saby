//
//  HMAC.swift
//  SabyAppleCrypto
//
//  Created by WOF on 2023/06/13.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation
import CommonCrypto

public enum HMAC: MessageAuthenticationCode {
    public static func code(message: String, key: String, hash: Hash) -> String {
        var result = Array<UInt8>(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        let algorithm = {
            switch hash {
            case .sha256:
                return CCHmacAlgorithm(kCCHmacAlgSHA256)
            }
        }()
        CCHmac(
            algorithm,
            key,
            key.utf8.count,
            message,
            message.utf8.count,
            &result
        )
        
        return result.reduce("") { $0 + String(format: "%02x", $1) }
    }
}

extension HMAC {
    public enum Hash: Int {
        case sha256
    }
}

#endif
