//
//  ThrowingTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import Testing
@testable import SabySafe

@Suite
struct ThrowingTest {
    @Test func defaultValue() {
        #expect((try? throwing()) == nil)
    }
    
    @Test func error() {
        #expect((try? throwing(TestError())) == nil)
    }
}

private struct TestError: Error {}
