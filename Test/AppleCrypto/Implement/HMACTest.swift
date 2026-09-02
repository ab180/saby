//
//  HMACTest.swift
//  SabyAppleCryptoTest
//
//  Created by WOF on 2023/06/13.
//

import Testing
@testable import SabyAppleCrypto

@Suite struct HMACTest {
    @Test func codeSHA256() {
        #expect(
            HMAC.code(message: "code", key: "key", hash: .sha256) ==
            "20ce5896cf7512e61eb5c706412d346310fb85e496a3be5ced028933cd1a38d7"
        )
        #expect(
            HMAC.code(message: "😇", key: "key", hash: .sha256) ==
            "91d7753db4ed888c5fb49c926e1e9cf271c049ad106f04055716c2b1606af47f"
        )
        #expect(
            HMAC.code(message: "code", key: "😇", hash: .sha256) ==
            "17ab0407e7addc045eb3229593f6968eafc51bcb7e2d179c06ec68b7f6bda5e9"
        )
        #expect(
            HMAC.code(message: "😇", key: "😇", hash: .sha256) ==
            "bee0ca9ddb342a445e4be39e54ecf641ca2a235cb1bdf04dd462305826728b3f"
        )
    }
}
