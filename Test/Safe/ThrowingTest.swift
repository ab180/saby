//
//  ThrowingTest.swift
//  SabySafeTest
//
//  Created by 0xwof on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class ThrowingTest: XCTestCase {
    func test__default_value() {
        XCTAssertNil(try? throwing())
    }
    
    func test__error() {
        XCTAssertNil(try? throwing(TestError()))
    }
}

private struct TestError: Error {}
