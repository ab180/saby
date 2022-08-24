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
        let NSDictionary = NSObject.Class(name: "NSDictionary")!
        let dictionaryWithValuesForKeys = NSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = NSDictionary.instance(
            object: NSDictionary.call(dictionaryWithValuesForKeys, with: ["1"], with: ["a"])
        )!
        
        XCTAssertNotNil(instance.method(name: "objectForKey:"))
        XCTAssertNil(instance.method(name: "1234567890"))
        XCTAssertNil(instance.method(name: ""))
    }
    
    func test__call() {
        let NSDictionary = NSObject.Class(name: "NSDictionary")!
        let dictionaryWithValuesForKeys = NSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = NSDictionary.instance(
            object: NSDictionary.call(dictionaryWithValuesForKeys, with: ["1"], with: ["a"])
        )!
        let objectForKey = instance.method(name: "objectForKey:")!
        
        XCTAssertEqual(instance.call(objectForKey, with: "a") as! String, "1")
    }
}
