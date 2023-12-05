//
//  JSONFilterTest.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import XCTest
@testable import SabyJSON

final class JSONFilterTest: XCTestCase {
    func test__deep_filter() {
        let json = JSON.from([
            "a": nil,
            "b": 1,
            "c": [
                "a": "a",
                "b": 1,
                "c": true,
                "d": [:],
                "e": []
            ],
            "d": [
                "a",
                1,
                true,
                nil,
                ["a":nil],
                [nil, nil]
            ],
            "e": nil,
        ])
        
        let filtered = json
            .deepFilter { $0 != .null }!
            .deepFilter { $0 != [:] }!
            .deepFilter { $0 != [] }!
        
        XCTAssertEqual(filtered, [
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
            ]
        ])
    }
}
