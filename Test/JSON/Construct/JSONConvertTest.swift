//
//  JSONConvertTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Foundation
import Testing
@testable import SabyJSON

@Suite struct JSONConvertTest {
    @Test func test__parse_string() {
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
        
        expectEqual(try! JSON.parse(string), json)
    }
    
    @Test func test__stringify() {
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
        
        expectEqual(json, decoded)
    }
    
    @Test func test__from_json_serialization() {
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
        
        expectEqual(
            try! JSON.from(unsafe: JSONSerialization.jsonObject(with: string.data(using: .utf8)!)),
            json
        )
    }
    
    @Test func test__from_encodable() {
        let json = JSON.from([
            "a": "123",
            "b": 10,
            "c": nil
        ])
        let encodable = Codable0(a: "123", b: 10, c: nil)
        
        expectEqual(try! JSON.encode(encodable), json)
    }
    
    @Test func test__from_encodable_nan() {
        let encodable = Codable0(a: "123", b: Double.nan, c: nil)
        let encoded = try! JSON.encode(encodable)
        
        expectEqual(encodable.a, encoded["a"]!.rawString)
        #expect(encodable.b.isNaN); #expect(encoded["b"]!.rawNumber!.isNaN)
        #expect(encoded["c"]!.raw == nil)
    }

    @Test func test__from_decodable() {
        let json: JSON = JSON.from([
            "a": "123",
            "b": 10,
            "c": nil
        ])
        let decodable = Codable0(a: "123", b: 10, c: nil)
        
        expectEqual(try! json.decode(Codable0.self), decodable)
    }
    
    @Test func test__from_decodable_nan() {
        let json: JSON = JSON.from([
            "a": "123",
            "b": Double.nan,
            "c": nil
        ])
        let decoded = try! json.decode(Codable0.self)
        let decodable = Codable0(a: "123", b: Double.nan, c: nil)
        
        expectEqual(decoded.a, decodable.a)
        #expect(decoded.b.isNaN); #expect(decodable.b.isNaN)
        expectEqual(decoded.c, decodable.c)
    }
    
    @Test func test__from_any() {
        expectEqual(try! JSON.from(unsafe: nil), JSON.from(nil))
        expectEqual(try! JSON.from(unsafe: "string"), JSON.from("string"))
        expectEqual(try! JSON.from(unsafe: 12345), JSON.from(12345))
        expectEqual(try! JSON.from(unsafe: true), JSON.from(true))
    }
    
    @Test func test__from_dictionary_string_any() {
        expectEqual(JSON.from(unsafe: [:]), [:])
        expectEqual(JSON.from(unsafe: ["valid":"1","invalid":JSONEncoder()]), JSON.from(["valid":"1"]))
        expectEqual(JSON.from(unsafe: ["valid":"1","invalid":Double.nan]), JSON.from(["valid":"1"]))
        expectEqual(JSON.from(unsafe: ["valid":nil,"invalid":JSONEncoder()]), JSON.from(["valid":nil]))
        expectEqual(
            JSON.from(unsafe: ["a":["a":nil as Any?],"b":["a":JSONEncoder()]]),
            JSON.from(["a":["a":nil],"b":[:]])
        )
    }
    
    @Test func test__from_dictionary_any_hashable_any() {
        expectEqual(JSON.from(unsafe: [:] as [AnyHashable : Any]), [:])
        expectEqual(JSON.from(unsafe: ["valid":"1","invalid":JSONEncoder(),0:"0"]), JSON.from(["valid":"1"]))
        expectEqual(JSON.from(unsafe: ["valid":nil,"invalid":JSONEncoder(),1:"1"]), JSON.from(["valid":nil]))
        expectEqual(
            JSON.from(unsafe: [
                "a":["a":nil,0:"0"] as [AnyHashable : Any?],
                "b":["a":JSONEncoder(),1:"1"] as [AnyHashable : Any?],
                2:"2"
            ]),
            JSON.from(["a":["a":nil],"b":[:]])
        )
    }
    
    @Test func test__from_array_any() {
        expectEqual(JSON.from(unsafe: []), [])
        expectEqual(JSON.from(unsafe: ["1",1,JSONEncoder()]), JSON.from(["1",1]))
        expectEqual(JSON.from(unsafe: [nil,1,JSONEncoder()]), JSON.from([nil,1]))
        expectEqual(JSON.from(unsafe: [[JSONEncoder(),nil],[1,2,3]]), JSON.from([[nil],[1,2,3]]))
    }
    
    @Test func test__from_nsnumber() {
        expectEqual(try! JSON.from(unsafe: NSNumber(integerLiteral: 1)), JSON.from(1))
        expectEqual(try! JSON.from(unsafe: NSNumber(floatLiteral: 1.0)), JSON.from(1.0))
        expectEqual(try! JSON.from(unsafe: NSNumber(booleanLiteral: true)), JSON.from(true))
        expectEqual(try! JSON.from(unsafe: NSNumber(booleanLiteral: false)), JSON.from(false))
    }
}
