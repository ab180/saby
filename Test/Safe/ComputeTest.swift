//
//  ComputeTest.swift
//  SabySafeTest
//
//  Created by 0xwof on 2022/08/08.
//

import XCTest
@testable import SabySafe

final class ComputeTest: XCTestCase {
    func test__compute() {
        XCTAssertEqual(compute { 10 }, 10)
    }
}
