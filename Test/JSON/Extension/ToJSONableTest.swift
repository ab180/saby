//
//  ToJSONableTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Testing
@testable import SabyJSON

@Suite struct ToJSONableTest {
    @Test func test__string_to_json() {
        let string: String = "string"
        expectEqual(string.toJSON(), .string("string"))
    }
    
    @Test func test__double_to_json() {
        let double: Double = 123456789.123456789
        expectEqual(double.toJSON(), .number(123456789.123456789))
    }
    
    @Test func test__float_to_json() {
        let float: Float = 123456789.123456789
        expectEqual(float.toJSON(), .number(Double(123456789.123456789 as Float)))
    }
    
    @Test func test__int64_to_json() {
        let int64: Int64 = 123456789
        expectEqual(int64.toJSON(), .number(123456789))
    }
    
    @Test func test__int32_to_json() {
        let int32: Int32 = 123456789
        expectEqual(int32.toJSON(), .number(123456789))
    }
    
    @Test func test__int16_to_json() {
        let int16: Int16 = 123
        expectEqual(int16.toJSON(), .number(123))
    }
    
    @Test func test__int8_to_json() {
        let int8: Int8 = 123
        expectEqual(int8.toJSON(), .number(123))
    }
    
    @Test func test__int_to_json() {
        let int: Int = 123456789
        expectEqual(int.toJSON(), .number(123456789))
    }
    
    @Test func test__uint64_to_json() {
        let uint64: UInt64 = 123456789
        expectEqual(uint64.toJSON(), .number(123456789))
    }
    
    @Test func test__uint32_to_json() {
        let uint32: UInt32 = 123456789
        expectEqual(uint32.toJSON(), .number(123456789))
    }
    
    @Test func test__uint16_to_json() {
        let uint16: UInt16 = 123
        expectEqual(uint16.toJSON(), .number(123))
    }
    
    @Test func test__uint8_to_json() {
        let uint8: UInt8 = 123
        expectEqual(uint8.toJSON(), .number(123))
    }
    
    @Test func test__uint_to_json() {
        let uint: UInt = 123456789
        expectEqual(uint.toJSON(), .number(123456789))
    }
    
    @Test func test__bool_to_json() {
        let bool: Bool = true
        expectEqual(bool.toJSON(), .boolean(true))
    }
    
    @Test func test__dictionary_to_json() {
        let dictionary: [String: ToJSONable?] = ["a": "a", "b": 1]
        expectEqual(dictionary.toJSON(), .object(["a": "a", "b": 1]))
    }
    
    @Test func test__array_to_json() {
        let array: [ToJSONable?] = ["a", 1]
        expectEqual(array.toJSON(), .array(["a", 1]))
    }
}
