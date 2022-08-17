//
//  RequireTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class RequireTest: XCTestCase {
    func test__success() {
        XCTAssertNotNil(try? require(Int.self, 10))
        XCTAssertNotNil(try? require(10 as Int?))
    }
    
    func test__fail() {
        XCTAssertNil(try? require(Int.self, "10"))
        XCTAssertNil(try? require(nil as Int?))
    }
}
