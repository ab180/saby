//
//  ComputeTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class ComputeTest: XCTestCase {
    func test__block() {
        XCTAssertEqual(compute { 10 }, 10)
    }
    
    func test__integer() {
        XCTAssertEqual(compute(Int.self, 10) { "\($0)" }, "10")
    }
    
    func test__string() {
        XCTAssertEqual(compute(Int.self, "10") { "\($0)" } , nil)
    }
    
    func test__nullable_integer() {
        XCTAssertEqual(compute(Int?.self, 10) { "\($0 ?? 0)" }, "10")
    }
}
