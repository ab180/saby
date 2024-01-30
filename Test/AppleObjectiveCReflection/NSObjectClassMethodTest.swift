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
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        
        XCTAssertNotNil(classNSDictionary.method(name: "dictionaryWithObjects:forKeys:"))
        XCTAssertNil(classNSDictionary.method(name: "1234567890"))
        XCTAssertNil(classNSDictionary.method(name: ""))
    }
    
    func test__call_return_reference() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodDictionaryWithValuesForKeys = classNSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        
        let dictionary = classNSDictionary.call(
            methodDictionaryWithValuesForKeys,
            with: ["1", "2", "3"],
            with: ["a", "b", "c"],
            return: .reference(NSDictionary.self)
        )!
        
        XCTAssertEqual(dictionary, ["a":"1","b":"2","c":"3"])
    }
    
    func test__call_return_value() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodIsProxy = classNSDictionary.method(name: "isProxy")!
        
        let isProxy = classNSDictionary.call(
            methodIsProxy,
            return: .value(Bool.self)
        )!
        
        XCTAssertEqual(isProxy, false)
    }
}
