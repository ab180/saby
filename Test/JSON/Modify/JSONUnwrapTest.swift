//
//  JSONUnwrapTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import XCTest
@testable import SabyJSON

final class JSONUnwrapTest: XCTestCase {
    func test__raw_string() {
        let json = JSON.from("string")
        XCTAssertEqual(json.rawString!, "string")
    }
    
    func test__raw_number() {
        let json = JSON.from(123)
        XCTAssertEqual(json.rawNumber!, 123)
    }
    
    func test__raw_boolean() {
        let json = JSON.from(true)
        XCTAssertEqual(json.rawBoolean!, true)
    }
    
    func test__raw_object() {
        let json = JSON.from([:])
        XCTAssertEqual(json.rawObject!, [:])
    }
    
    func test__raw_array() {
        let json = JSON.from([])
        XCTAssertEqual(json.rawArray, [])
    }
    
    func test__raw() {
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
        XCTAssertEqual(try JSON.from(unsafe: json.raw), json)
    }
    
    func test__is_string() {
        let json = JSON.from("string")
        XCTAssertTrue(json.isString)
    }
    
    func test__is_number() {
        let json = JSON.from(123)
        XCTAssertTrue(json.isNumber)
    }
    
    func test__is_boolean() {
        let json = JSON.from(true)
        XCTAssertTrue(json.isBoolean)
    }
    
    func test__is_object() {
        let json = JSON.from([:])
        XCTAssertTrue(json.isObject)
    }
    
    func test__is_array() {
        let json = JSON.from([])
        XCTAssertTrue(json.isArray)
    }
    
    func test__is_null() {
        let json = JSON.from(nil)
        XCTAssertTrue(json.isNull)
    }
}
