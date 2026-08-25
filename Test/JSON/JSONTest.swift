//
//  JSONTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Testing
@testable import SabyJSON

@Suite struct JSONTest {
    @Test func test__string() {
        let json = JSON.string("string")
        expectEqual(json, "string")
    }
    
    @Test func test__number() {
        let json = JSON.number(123456789012345)
        expectEqual(json, 123456789012345)
    }
    
    @Test func test__boolean() {
        let json = JSON.boolean(true)
        expectEqual(json, true)
    }
    
    @Test func test__object() {
        let json = JSON.object([:])
        expectEqual(json, [:])
    }
    
    @Test func test__array() {
        let json = JSON.array([])
        expectEqual(json, [])
    }
    
    @Test func test__null() {
        let json = JSON.null
        expectEqual(json, .null)
    }
}
