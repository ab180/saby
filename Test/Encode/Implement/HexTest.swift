//
//  HexTest.swift
//  SabyEncodeTest
//
//  Created by WOF on 2023/02/27.
//

import Foundation
import Testing
@testable import SabyEncode

@Suite
struct HexTest {
    @Test func encodeData() throws {
        #expect(Hex.encode(data: try #require("string".data(using: .utf8))) == "737472696e67")
        #expect(Hex.encode(data: try #require("가나다".data(using: .utf8))) == "eab080eb8298eb8ba4")
        #expect(Hex.encode(data: try #require("😇".data(using: .utf8))) == "f09f9887")
    }
}
