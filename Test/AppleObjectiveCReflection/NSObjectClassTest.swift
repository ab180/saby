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
        XCTAssertNotNil(NSObject.Class(name: "NSDictionary"))
        XCTAssertNotNil(NSObject.Class(name: "NSArray"))
        XCTAssertNil(NSObject.Class(name: "1234567890"))
        XCTAssertNil(NSObject.Class(name: ""))
    }
}
