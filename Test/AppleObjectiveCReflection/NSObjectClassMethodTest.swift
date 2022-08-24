//
//  NSObjectClassMethodTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import XCTest
@testable import SabyAppleObjectiveCReflection

final class NSObjectClassMethodTest: XCTestCase {
    func test__init_class_method() {
        let NSDictionary = NSObject.Class(name: "NSDictionary")!
        
        XCTAssertNotNil(NSDictionary.method(name: "dictionaryWithObjects:forKeys:"))
        XCTAssertNil(NSDictionary.method(name: "1234567890"))
        XCTAssertNil(NSDictionary.method(name: ""))
    }
    
    func test__call() {
        let NSDictionary = NSObject.Class(name: "NSDictionary")!
        let dictionaryWithValuesForKeys = NSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        
        let dictionary = NSDictionary.call(
            dictionaryWithValuesForKeys,
            with: ["1", "2", "3"],
            with: ["a", "b", "c"]
        ) as! NSDictionary
        
        XCTAssertEqual(dictionary, ["a":"1","b":"2","c":"3"])
    }
}
