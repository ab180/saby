//
//  JSONTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import XCTest
@testable import SabyJSON

final class JSONTest: XCTestCase {
    func test__string() {
        let json = JSON.string("string")
        XCTAssertEqual(json, "string")
    }
    
    func test__number() {
        let json = JSON.number(123456789012345)
        XCTAssertEqual(json, 123456789012345)
    }
    
    func test__boolean() {
        let json = JSON.boolean(true)
        XCTAssertEqual(json, true)
    }
    
    func test__object() {
        let json = JSON.object([:])
        XCTAssertEqual(json, [:])
    }
    
    func test__array() {
        let json = JSON.array([])
        XCTAssertEqual(json, [])
    }
    
    func test__null() {
        let json = JSON.null
        XCTAssertEqual(json, .null)
    }
}
