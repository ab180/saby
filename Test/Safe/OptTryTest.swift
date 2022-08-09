//
//  OptTryTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class OptTryTest: XCTestCase {
    func test__success() {
        XCTAssertEqual(optTry { 10 }, 10)
    }
    
    func test__fail() {
        XCTAssertEqual(optTry { () -> Int in throw TestError() }, nil)
    }
}

private struct TestError: Error {}
