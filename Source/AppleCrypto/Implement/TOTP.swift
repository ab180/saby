//
//  TOTP.swift
//  SabyAppleCrypto
//
//  Created by WOF on 2023/06/13.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation
import CommonCrypto
import SabyTime

public enum TOTP: OneTimePassword {
    public static func password(
        timestamp: Timestamp,
        key: String,
        hash: Hash,
        interval: Interval,
        digit: Digit
    ) -> String {
        let message = {
            var array = Array<UInt8>(repeating: 0, count: 8)

            let step = UInt64(timestamp.secondFrom1970) / UInt64(interval.second)
            array[0] = UInt8((step & 0xFF00000000000000) >> 56)
            array[1] = UInt8((step & 0x00FF000000000000) >> 48)
            array[2] = UInt8((step & 0x0000FF0000000000) >> 40)
            array[3] = UInt8((step & 0x000000FF00000000) >> 32)
            array[4] = UInt8((step & 0x00000000FF000000) >> 24)
            array[5] = UInt8((step & 0x0000000000FF0000) >> 16)
            array[6] = UInt8((step & 0x000000000000FF00) >> 8)
            array[7] = UInt8((step & 0x00000000000000FF) >> 0)

            return array
        }()
        let code = {
            var array = Array<UInt8>(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

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
                message.count,
                &array
            )

            return array
        }()
        let password = {
            let offset = Int(code[code.count - 1] & 0x0F)
            let seed = (
                (UInt32(code[offset] & 0x7F) << 24)
                | (UInt32(code[offset + 1] & 0xFF) << 16)
                | (UInt32(code[offset + 2] & 0xFF) << 8)
                | (UInt32(code[offset + 3] & 0xFf) << 0)
            )
            return String(format: "%08d", seed % digit.mask)
        }()
        
        return password
    }
}

extension TOTP {
    public enum Hash: Int {
        case sha256 = 0
    }
}

extension TOTP {
    public enum Digit: Int {
        case digit0 = 0
        case digit1
        case digit2
        case digit3
        case digit4
        case digit5
        case digit6
        case digit7
        case digit8
    }
}

extension TOTP.Digit {
    var mask: UInt32 {
        switch self {
        case .digit0: return 1
        case .digit1: return 10
        case .digit2: return 100
        case .digit3: return 1000
        case .digit4: return 10000
        case .digit5: return 100000
        case .digit6: return 1000000
        case .digit7: return 10000000
        case .digit8: return 100000000
        }
    }
}

#endif
