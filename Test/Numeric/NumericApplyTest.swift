//
//  NumericApplyTest.swift
//  SabyNumericTest
//
//  Created by WOF on 2022/08/19.
//

import XCTest
@testable import SabyNumeric

final class NumericApplyTest: XCTestCase {
    func test__applied_limit_closed_range() {
        XCTAssertEqual((100).applied(limit: 0...200), 100)
        XCTAssertEqual((-100).applied(limit: 0...200), 0)
        XCTAssertEqual((300).applied(limit: 0...200), 200)
    }
    
    func test__applied_limit_minimum_maximum() {
        XCTAssertEqual((100).applied(minimum: 0, maximum: 200), 100)
        XCTAssertEqual((-100).applied(minimum: 0, maximum: 200), 0)
        XCTAssertEqual((300).applied(minimum: 0, maximum: 200), 200)
    }
    
    func test__applied_limit_partial_range_through() {
        XCTAssertEqual((100).applied(limit: ...200), 100)
        XCTAssertEqual((300).applied(limit: ...200), 200)
    }
    
    func test__applied_limit_maximum() {
        XCTAssertEqual((100).applied(maximum: 200), 100)
        XCTAssertEqual((300).applied(maximum: 200), 200)
    }
    
    func test__applied_limit_partial_range_from() {
        XCTAssertEqual((100).applied(limit: 0...), 100)
        XCTAssertEqual((-100).applied(limit: 0...), 0)
    }
    
    func test__applied_limit_minimum() {
        XCTAssertEqual((100).applied(minimum: 0), 100)
        XCTAssertEqual((-100).applied(minimum: 0), 0)
    }
}
