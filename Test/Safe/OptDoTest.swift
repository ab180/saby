//
//  OptDoTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class OptDoTest: XCTestCase {
    func test__success() {
        XCTAssertEqual(optDo { 10 }, 10)
    }
    
    func test__fail() {
        XCTAssertEqual(optDo { () -> Int in throw TestError() }, nil)
    }
}

private struct TestError: Error {}
