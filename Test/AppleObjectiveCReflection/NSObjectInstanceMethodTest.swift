//
//  NSObjectInstanceMethodTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import XCTest
@testable import SabyAppleObjectiveCReflection

final class NSObjectInstanceMethodTest: XCTestCase {
    func test__init_class_method() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodDictionaryWithValuesForKeys = classNSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = classNSDictionary.instance(
            object: classNSDictionary.call(methodDictionaryWithValuesForKeys, with: ["1"], with: ["a"], return: .reference)
        )!
        
        XCTAssertNotNil(instance.method(name: "objectForKey:"))
        XCTAssertNil(instance.method(name: "1234567890"))
        XCTAssertNil(instance.method(name: ""))
    }
    
    func test__call_return_reference() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodDictionaryWithValuesForKeys = classNSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = classNSDictionary.instance(
            object: classNSDictionary.call(methodDictionaryWithValuesForKeys, with: ["1"], with: ["a"], return: .reference)
        )!
        let methodObjectForKey = instance.method(name: "objectForKey:")!
        
        XCTAssertEqual(instance.call(methodObjectForKey, with: "a", return: .reference(String.self))!, "1")
    }
    
    func test__call_return_value() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodDictionaryWithValuesForKeys = classNSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = classNSDictionary.instance(
            object: classNSDictionary.call(methodDictionaryWithValuesForKeys, with: ["1"], with: ["a"], return: .reference)
        )!
        let methodCount = instance.method(name: "count")!
        
        XCTAssertEqual(instance.call(methodCount, return: .value(Int.self))!, 1)
    }
}
