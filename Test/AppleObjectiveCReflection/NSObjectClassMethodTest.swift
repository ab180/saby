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
        
        let dictionary = {
            let function = unsafeBitCast(
                methodDictionaryWithValuesForKeys.implementation,
                to: (@convention(c)(AnyClass, Selector, [String], [String])->[String: String]).self
            )
            return function(
                methodDictionaryWithValuesForKeys.anyClass,
                methodDictionaryWithValuesForKeys.selector,
                ["1", "2", "3"],
                ["a", "b", "c"]
            )
        }()
        
        XCTAssertEqual(dictionary, ["a":"1","b":"2","c":"3"])
    }
    
    func test__call_return_value() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodIsProxy = classNSDictionary.method(name: "isProxy")!
        
        let isProxy = {
            let function = unsafeBitCast(
                methodIsProxy.implementation,
                to: (@convention(c)(AnyClass, Selector)->Bool).self
            )
            return function(
                methodIsProxy.anyClass,
                methodIsProxy.selector
            )
        }()
        
        XCTAssertEqual(isProxy, false)
    }
}
