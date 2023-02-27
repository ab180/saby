//
//  HexTest.swift
//  SabyEncodeTest
//
//  Created by WOF on 2023/02/27.
//

import XCTest
@testable import SabyEncode

final class HexTest: XCTestCase {
    func test__encode_data() {
        XCTAssertEqual(
            Hex.encode(data: "string".data(using: .utf8)!),
            "737472696e67"
        )
        XCTAssertEqual(
            Hex.encode(data: "가나다".data(using: .utf8)!),
            "eab080eb8298eb8ba4"
        )
        XCTAssertEqual(
            Hex.encode(data: "😇".data(using: .utf8)!),
            "f09f9887"
        )
    }
}
