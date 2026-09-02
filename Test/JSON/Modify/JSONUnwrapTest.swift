//
//  JSONUnwrapTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Testing
@testable import SabyJSON

@Suite struct JSONUnwrapTest {
    @Test func test__raw_string() {
        let json = JSON.from("string")
        expectEqual(json.rawString!, "string")
    }
    
    @Test func test__raw_number() {
        let json = JSON.from(123)
        expectEqual(json.rawNumber!, 123)
    }
    
    @Test func test__raw_boolean() {
        let json = JSON.from(true)
        expectEqual(json.rawBoolean!, true)
    }
    
    @Test func test__raw_object() {
        let json = JSON.from([:])
        expectEqual(json.rawObject!, [:])
    }
    
    @Test func test__raw_array() {
        let json = JSON.from([])
        expectEqual(json.rawArray, [])
    }
    
    @Test func test__raw() throws {
        let json = JSON.from([
            "a": "a",
            "b": 1,
            "c": [
                "a": "a",
                "b": 1,
                "c": true
            ],
            "d": [
                "a",
                1,
                true
            ],
            "e": nil
        ])
        expectEqual(try JSON.from(unsafe: json.raw), json)
    }
    
    @Test func test__is_string() {
        let json = JSON.from("string")
        #expect(json.isString)
    }
    
    @Test func test__is_number() {
        let json = JSON.from(123)
        #expect(json.isNumber)
    }
    
    @Test func test__is_boolean() {
        let json = JSON.from(true)
        #expect(json.isBoolean)
    }
}
