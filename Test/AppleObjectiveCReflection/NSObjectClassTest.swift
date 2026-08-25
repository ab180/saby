//
//  NSObjectClassTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import Testing
@testable import SabyAppleObjectiveCReflection

@Suite struct NSObjectClassTest {
    @Test func initialize() {
        #expect(NSObjectClass(name: "NSDictionary") != nil)
        #expect(NSObjectClass(name: "NSArray") != nil)
        #expect(NSObjectClass(name: "1234567890") == nil)
        #expect(NSObjectClass(name: "") == nil)
    }
}
