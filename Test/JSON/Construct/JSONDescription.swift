//
//  JSONDescription.swift
//  SabyJSON
//
//  Created by 0xwof on 2022/08/17.
//

import Foundation

import XCTest
@testable import SabyJSON

final class JSONDescriptionTest: XCTestCase {
    func test__debug_description() {
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

        let string = json.debugDescription
            .replacingOccurrences(of: "^JSON\\(", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\)$", with: "", options: .regularExpression)
        let data = string.data(using: .utf8)!
        let decoded = try! JSONDecoder().decode(JSON.self, from: data)
        
        XCTAssertEqual(json, decoded)
    }
}
