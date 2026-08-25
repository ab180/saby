//
//  NSObjectInstanceMethodTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import Foundation
import Testing
@testable import SabyAppleObjectiveCReflection

final class NSObjectInstanceMethodTest {
    @Test func init_class_method() {
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
        
        #expect(instance.method(name: "objectForKey:") != nil)
        #expect(instance.method(name: "1234567890") == nil)
        #expect(instance.method(name: "") == nil)
    }
    
    @Test func call_return_reference() {
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
        
        #expect({
            let function = unsafeBitCast(
                methodObjectForKey.implementation,
                to: (@convention(c)(NSObject, Selector, String)->String).self
            )
            return function(
                methodObjectForKey.object,
                methodObjectForKey.selector,
                "a"
            )
        }() == "1")
    }
    
    @Test func call_return_value() {
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
        
        #expect({
            let function = unsafeBitCast(
                methodCount.implementation,
                to: (@convention(c)(NSObject, Selector)->Int).self
            )
            return function(
                methodCount.object,
                methodCount.selector
            )
        }() == 1)
    }
}
