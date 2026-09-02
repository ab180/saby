//
//  NSObjectGlobalTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2023/04/27.
//

import Testing
@testable import SabyAppleObjectiveCReflection

import Foundation

@Suite struct NSObjectGlobalTest {
    @Test func variable() {
        #expect(NSObjectGlobal.variable(
            type: NSString.self,
            name: "kCFLocaleCurrentLocaleDidChangeNotification"
        ) != nil)
        #expect(NSObjectGlobal.variable(
            type: NSString.self,
            name: ""
        ) == nil)
    }
}
