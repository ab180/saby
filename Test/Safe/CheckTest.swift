//
//  CheckTest.swift
//  SabySafeTest
//
//  Created by 0xwof on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class CheckTest: XCTestCase {
    func test__integer() {
        XCTAssertEqual(check(Int.self, 10), true)
    }
    
    func test__string() {
        XCTAssertEqual(check(String.self, "10"), true)
    }
    
    func test__nullable_integer() {
        XCTAssertEqual(check(Int?.self, 10), true)
        XCTAssertEqual(check(Int?.self, nil), true)
    }
    
    func test__nullable_string() {
        XCTAssertEqual(check(String?.self, "10"), true)
        XCTAssertEqual(check(String?.self, nil), true)
    }
}
