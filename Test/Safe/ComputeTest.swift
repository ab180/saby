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
    
    func test__type_integer() {
        XCTAssertEqual(compute(.type(Int.self), 10) { "\($0)" }, "10")
    }
    
    func test__type_string() {
        XCTAssertEqual(compute(.type(Int.self), "10") { "\($0)" } , nil)
    }
    
    func test__non_null_integer() {
        XCTAssertEqual(compute(.nonNull, 10) { "\($0)" }, "10")
    }
}
