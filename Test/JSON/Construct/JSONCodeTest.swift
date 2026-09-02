//
//  JSONCodeTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Foundation
import Testing
@testable import SabyJSON

@Suite struct JSONCodeTest {
    @Test func test__encode() {
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
        
        let encoded = try! JSONEncoder().encode(json)
        let decoded = try! JSONDecoder().decode(JSON.self, from: encoded)
        
        expectEqual(json, decoded)
    }
    
    @Test func test__decode() {
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
        let string = """
        {
            "a": "a",
            "b": 1,
            "c": {
                "a": "a",
                "b": 1,
                "c": true
            },
            "d": [
                "a",
                1,
                true
            ],
            "e": null
        }
        """
        
        let data = string.data(using: .utf8)!
        let decoded = try! JSONDecoder().decode(JSON.self, from: data)
        
        expectEqual(json, decoded)
    }
}
