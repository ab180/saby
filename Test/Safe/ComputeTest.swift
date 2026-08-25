//
//  ComputeTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import Testing
@testable import SabySafe

@Suite
struct ComputeTest {
    @Test func value() {
        #expect(compute(10) { "\($0)" } == "10")
    }
    
    @Test func nonNullInteger() {
        #expect(compute(.nonNull, 10) { "\($0)" } == "10")
    }
}
