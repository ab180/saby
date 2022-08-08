//
//  RequireTest.swift
//  SabySafeTest
//
//  Created by 0xwof on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class RequireTest: XCTestCase {
    func test__success() {
        XCTAssertNotNil(try? require(Int.self, 10))
    }
    
    func test__fail() {
        XCTAssertNil(try? require(Int.self, "10"))
    }
}
