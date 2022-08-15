//
//  JSONExpressionTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import XCTest
@testable import SabyJSON

final class JSONExpressionTest: XCTestCase {
    func test__init_string_literal() {
        let json: JSON = "string"
        
        XCTAssertEqual(json, "string")
        XCTAssertEqual(json, .string("string"))
    }
    
    func test__init_integer_literal() {
        let json: JSON = 123456789
        
        XCTAssertEqual(json, 123456789)
        XCTAssertEqual(json, .number(123456789))
    }
    
    func test__init_float_literal() {
        let json: JSON = 123456789.123456789
        
        XCTAssertEqual(json, 123456789.123456789)
        XCTAssertEqual(json, .number(123456789.123456789))
    }
    
    func test__init_boolean_literal() {
        let json: JSON = true
        
        XCTAssertEqual(json, true)
        XCTAssertEqual(json, .boolean(true))
    }
    
    func test__init_dictionary_literal() {
        let json: JSON = [:]
        
        XCTAssertEqual(json, [:])
        XCTAssertEqual(json, .object([:]))
    }
    
    func test__init_array_literal() {
        let json: JSON = []
        
        XCTAssertEqual(json, [])
        XCTAssertEqual(json, .array([]))
    }
    
    func test__init_nil_literal() {
        let json: JSON = nil
        
        XCTAssertEqual(json, nil)
        XCTAssertEqual(json, .null)
    }
}
