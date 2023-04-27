//
//  NSObjectGlobalTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2023/04/27.
//

import XCTest
@testable import SabyAppleObjectiveCReflection

import Foundation

final class NSObjectGlobalTest: XCTestCase {
    func test__variable() {
        XCTAssertNotNil(NSObjectGlobal.variable(
            type: NSString.self,
            name: "kCFLocaleCurrentLocaleDidChangeNotification"
        ))
        XCTAssertNil(NSObjectGlobal.variable(
            type: NSString.self,
            name: ""
        ))
    }
}
