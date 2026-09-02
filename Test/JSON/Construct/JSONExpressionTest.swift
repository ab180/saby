//
//  JSONExpressionTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Testing
@testable import SabyJSON

@Suite struct JSONExpressionTest {
    @Test func test__init_string_literal() {
        let json: JSON = "string"
        
        expectEqual(json, "string")
        expectEqual(json, .string("string"))
    }
    
    @Test func test__init_integer_literal() {
        let json: JSON = 123456789
        
        expectEqual(json, 123456789)
        expectEqual(json, .number(123456789))
    }
    
    @Test func test__init_float_literal() {
        let json: JSON = 123456789.123456789
        
        expectEqual(json, 123456789.123456789)
        expectEqual(json, .number(123456789.123456789))
    }
    
    @Test func test__init_boolean_literal() {
        let json: JSON = true
        
        expectEqual(json, true)
        expectEqual(json, .boolean(true))
    }
    
    @Test func test__init_dictionary_literal() {
        let json: JSON = [:]
        
        expectEqual(json, [:])
        expectEqual(json, .object([:]))
    }
    
    @Test func test__init_array_literal() {
        let json: JSON = []
        
        expectEqual(json, [])
        expectEqual(json, .array([]))
    }
}
