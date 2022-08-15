//
//  JSONAccessTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import XCTest
@testable import SabyJSON

final class JSONAccessTest: XCTestCase {
    func test__get_access_single_key() {
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
        
        XCTAssertEqual(json["a"]!, "a")
        XCTAssertEqual(json["b"]!, 1)
        XCTAssertEqual(json["c"]!["a"], "a")
        XCTAssertEqual(json["d"]![2], true)
        XCTAssertEqual(json["e"]!, nil)
    }
    
    func test__get_access_multiple_key() {
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
        
        XCTAssertEqual(json["c", "a"]!, "a")
        XCTAssertEqual(json["d", 2]!, true)
    }
    
    func test__set_access_single_key() {
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
        XCTAssertEqual(json["a"]!, [1,2,3])
        json["b"]! = nil
        XCTAssertEqual(json["b"]!, nil)
        json["c"]!["a"]! = "string"
        XCTAssertEqual(json["c"]!["a"]!, "string")
        json["d"]![1]! = 123
        XCTAssertEqual(json["d"]![1]!, 123)
        json["e"]! = [:]
        XCTAssertEqual(json["e"]!, [:])
    }
    
    func test__set_access_multiple_key() {
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
        XCTAssertEqual(json["c", "a"]!, "string")
        json["d", 1]! = 123
        XCTAssertEqual(json["d", 1]!, 123)
    }
    
    func test__delete() {
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
        
        json["c"]!.delete("a")
        json["d"]!.delete(1)
        
        XCTAssertEqual(json["c"]!, ["b":1,"c":true])
        XCTAssertEqual(json["d"]!, ["a",true])
    }
    
    func test__delete_if_object() {
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
        
        json["c"]!.delete(ifObject: "a")
        
        XCTAssertEqual(json["c"]!, ["b":1,"c":true])
    }
    
    func test__delete_if_array() {
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
        
        json["d"]!.delete(ifArray: 1)
        
        XCTAssertEqual(json["d"]!, ["a",true])
    }
    
    func test__push() {
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
        
        json["d"]!.push(nil)
        
        XCTAssertEqual(json["d"]!, ["a",1,true,nil])
    }
    
    func test__push_if_array() {
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
        
        json["d"]!.push(ifArray: nil)
        
        XCTAssertEqual(json["d"]!, ["a",1,true,nil])
    }
}
