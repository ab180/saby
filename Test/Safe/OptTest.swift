//
//  OptTest.swift
//  SabySafeTest
//
//  Created by 0xwof on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class OptTest: XCTestCase {
    func test__integer() {
        XCTAssertEqual(opt(Int.self, 10), 10)
    }
    
    func test__string() {
        XCTAssertEqual(opt(String.self, "10"), "10")
    }
    
    func test__nullable_integer() {
        XCTAssertEqual(opt(Int?.self, 10), 10)
        XCTAssertEqual(opt(Int?.self, nil), nil)
    }
    
    func test__nullable_string() {        
        XCTAssertEqual(opt(String?.self, "10"), "10")
        XCTAssertEqual(opt(String?.self, nil), nil)
    }
}
