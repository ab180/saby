//
//  TOTPTest.swift
//  SabyAppleCryptoTest
//
//  Created by WOF on 2023/06/13.
//

import XCTest
import SabyTime
@testable import SabyAppleCrypto

final class TOTPTest: XCTestCase {
    func test__password_sha256() {
        XCTAssertEqual(
            TOTP.password(
                timestamp: Timestamp(secondFrom1970: 59),
                key: "12345678901234567890123456789012",
                hash: .sha256,
                interval: Interval.second(30),
                digit: .digit8
            ),
            "46119246"
        )
        XCTAssertEqual(
            TOTP.password(
                timestamp: Timestamp(secondFrom1970: 1111111109),
                key: "12345678901234567890123456789012",
                hash: .sha256,
                interval: Interval.second(30),
                digit: .digit8
            ),
            "68084774"
        )
        XCTAssertEqual(
            TOTP.password(
                timestamp: Timestamp(secondFrom1970: 1111111111),
                key: "12345678901234567890123456789012",
                hash: .sha256,
                interval: Interval.second(30),
                digit: .digit8
            ),
            "67062674"
        )
        XCTAssertEqual(
            TOTP.password(
                timestamp: Timestamp(secondFrom1970: 1234567890),
                key: "12345678901234567890123456789012",
                hash: .sha256,
                interval: Interval.second(30),
                digit: .digit8
            ),
            "91819424"
        )
        XCTAssertEqual(
            TOTP.password(
                timestamp: Timestamp(secondFrom1970: 2000000000),
                key: "12345678901234567890123456789012",
                hash: .sha256,
                interval: Interval.second(30),
                digit: .digit8
            ),
            "90698825"
        )
        XCTAssertEqual(
            TOTP.password(
                timestamp: Timestamp(secondFrom1970: 20000000000),
                key: "12345678901234567890123456789012",
                hash: .sha256,
                interval: Interval.second(30),
                digit: .digit8
            ),
            "77737706"
        )
    }
}
