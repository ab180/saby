//
//  ConvertTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class ConvertTest: XCTestCase {
    func test__integer() {
        XCTAssertEqual(convert(Int.self, 10) { "\($0)" }, "10")
    }
    
    func test__string() {
        XCTAssertEqual(convert(Int.self, "10") { "\($0)" } , nil)
    }
    
    func test__nullable_integer() {
        XCTAssertEqual(convert(Int?.self, 10) { "\($0 ?? 0)" }, "10")
    }
}
