//
//  JSONAccessTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Testing
@testable import SabyJSON

@Suite struct JSONAccessTest {
    @Test func test__get_access_single_key() {
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
        
        expectEqual(json["a"]!, JSON.from("a"))
        expectEqual(json["b"]!, JSON.from(1))
        expectEqual(json["c"]!["a"], JSON.from("a"))
        expectEqual(json["d"]![2], JSON.from(true))
        expectEqual(json["e"]!, JSON.from(nil))
    }
    
    @Test func test__get_access_multiple_key() {
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
        
        expectEqual(json["c", "a"]!, JSON.from("a"))
        expectEqual(json["d", 2]!, JSON.from(true))
    }
    
    @Test func test__set_access_single_key() {
        var json = JSON.from([
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
        
        json["a"]! = [1,2,3]
        expectEqual(json["a"]!, JSON.from([1,2,3]))
        json["b"]! = .null
        expectEqual(json["b"]!, JSON.from(nil))
        json["c"]!["a"]! = "string"
        expectEqual(json["c"]!["a"]!, JSON.from("string"))
        json["d"]![1]! = 123
        expectEqual(json["d"]![1]!, JSON.from(123))
        json["e"]! = [:]
        expectEqual(json["e"]!, JSON.from([:]))
    }
    
    @Test func test__set_access_multiple_key() {
        var json = JSON.from([
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
        
        json["c", "a"]! = "string"
        expectEqual(json["c", "a"]!, JSON.from("string"))
        json["d", 1]! = 123
        expectEqual(json["d", 1]!, JSON.from(123))
    }
}
