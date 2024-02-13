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
            object: {
                let function = unsafeBitCast(
                    methodDictionaryWithValuesForKeys.implementation,
                    to: (@convention(c)(AnyClass, Selector, [String], [String])->[String: String]).self
                )
                return function(
                    methodDictionaryWithValuesForKeys.anyClass,
                    methodDictionaryWithValuesForKeys.selector,
                    ["1"],
                    ["a"]
                )
            }()
        )!
        
        XCTAssertNotNil(instance.method(name: "objectForKey:"))
        XCTAssertNil(instance.method(name: "1234567890"))
        XCTAssertNil(instance.method(name: ""))
    }
    
    func test__call_return_reference() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodDictionaryWithValuesForKeys = classNSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = classNSDictionary.instance(
            object: {
                let function = unsafeBitCast(
                    methodDictionaryWithValuesForKeys.implementation,
                    to: (@convention(c)(AnyClass, Selector, [String], [String])->[String: String]).self
                )
                return function(
                    methodDictionaryWithValuesForKeys.anyClass,
                    methodDictionaryWithValuesForKeys.selector,
                    ["1"],
                    ["a"]
                )
            }()
        )!
        let methodObjectForKey = instance.method(name: "objectForKey:")!
        
        XCTAssertEqual({
            let function = unsafeBitCast(
                methodObjectForKey.implementation,
                to: (@convention(c)(NSObject, Selector, String)->String).self
            )
            return function(
                methodObjectForKey.object,
                methodObjectForKey.selector,
                "a"
            )
        }(), "1")
    }
    
    func test__call_return_value() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let methodDictionaryWithValuesForKeys = classNSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = classNSDictionary.instance(
            object: {
                let function = unsafeBitCast(
                    methodDictionaryWithValuesForKeys.implementation,
                    to: (@convention(c)(AnyClass, Selector, [String], [String])->[String: String]).self
                )
                return function(
                    methodDictionaryWithValuesForKeys.anyClass,
                    methodDictionaryWithValuesForKeys.selector,
                    ["1"],
                    ["a"]
                )
            }()
        )!
        let methodCount = instance.method(name: "count")!
        
        XCTAssertEqual({
            let function = unsafeBitCast(
                methodCount.implementation,
                to: (@convention(c)(NSObject, Selector)->Int).self
            )
            return function(
                methodCount.object,
                methodCount.selector
            )
        }(), 1)
    }
}
