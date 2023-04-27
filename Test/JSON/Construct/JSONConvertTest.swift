//
//  JSONConvertTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import XCTest
@testable import SabyJSON

final class JSONConvertTest: XCTestCase {
    func test__parse_string() {
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
        
        XCTAssertEqual(try! JSON.parse(string), json)
    }
    
    func test__stringify() {
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
        
        let data = try! json.stringify().data(using: .utf8)!
        let decoded = try! JSONDecoder().decode(JSON.self, from: data)
        
        XCTAssertEqual(json, decoded)
    }
    
    func test__from_encodable() {
        let json = JSON.from([
            "a": "123",
            "b": 10,
            "c": nil
        ])
        let encodable = Codable0(a: "123", b: 10, c: nil)
        
        XCTAssertEqual(try! JSON.encode(encodable), json)
    }
    
    func test__from_decodable() {
        let json: JSON = JSON.from([
            "a": "123",
            "b": 10,
            "c": nil
        ])
        let decodable = Codable0(a: "123", b: 10, c: nil)
        
        
        
        XCTAssertEqual(try! json.decode(Codable0.self), decodable)
    }
    
    func test__from_any() {
        XCTAssertEqual(try! JSON.from(unsafe: nil), JSON.from(nil))
        XCTAssertEqual(try! JSON.from(unsafe: "string"), JSON.from("string"))
        XCTAssertEqual(try! JSON.from(unsafe: 12345), JSON.from(12345))
        XCTAssertEqual(try! JSON.from(unsafe: true), JSON.from(true))
    }
    
    func test__from_dictionary_string_any() {
        XCTAssertEqual(JSON.from(unsafe: [:]), [:])
        XCTAssertEqual(JSON.from(unsafe: ["valid":"1","invalid":JSONEncoder()]), JSON.from(["valid":"1"]))
        XCTAssertEqual(JSON.from(unsafe: ["valid":nil,"invalid":JSONEncoder()]), JSON.from(["valid":nil]))
        XCTAssertEqual(
            JSON.from(unsafe: ["a":["a":nil as Any?],"b":["a":JSONEncoder()]]),
            JSON.from(["a":["a":nil],"b":[:]])
        )
    }
    
    func test__from_array_any() {
        XCTAssertEqual(JSON.from(unsafe: []), [])
        XCTAssertEqual(JSON.from(unsafe: ["1",1,JSONEncoder()]), JSON.from(["1",1]))
        XCTAssertEqual(JSON.from(unsafe: [nil,1,JSONEncoder()]), JSON.from([nil,1]))
        XCTAssertEqual(JSON.from(unsafe: [[JSONEncoder(),nil],[1,2,3]]), JSON.from([[nil],[1,2,3]]))
    }
}
