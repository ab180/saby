//
//  NSObjectClassTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import XCTest
@testable import SabyAppleObjectiveCReflection

final class NSObjectClassTest: XCTestCase {
    func test__init() {
        XCTAssertNotNil(NSObjectClass(name: "NSDictionary"))
        XCTAssertNotNil(NSObjectClass(name: "NSArray"))
        XCTAssertNil(NSObjectClass(name: "1234567890"))
        XCTAssertNil(NSObjectClass(name: ""))
    }
}
