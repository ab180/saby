//
//  NSObjectClassMethodTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import Foundation
import Testing
@testable import SabyAppleObjectiveCReflection

final class NSObjectClassMethodTest {
    @Test func init_class_method() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        
        #expect(classNSDictionary.method(name: "dictionaryWithObjects:forKeys:") != nil)
        #expect(classNSDictionary.method(name: "1234567890") == nil)
        #expect(classNSDictionary.method(name: "") == nil)
    }
    
    @Test func call_return_reference() {
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
        
        #expect(dictionary == ["a":"1","b":"2","c":"3"])
    }
    
    @Test func call_return_value() {
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
        
        #expect(isProxy == false)
    }
}
