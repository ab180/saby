//
//  RequireTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/08.
//

import Testing
@testable import SabySafe

@Suite
struct RequireTest {
    @Test func success() {
        #expect((try? require(10 as Int?)) != nil)
    }
    
    @Test func fail() {
        #expect((try? require(nil as Int?)) == nil)
    }
}
