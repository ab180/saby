//
//  NSObjectInstanceTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import Foundation
import Testing
@testable import SabyAppleObjectiveCReflection

final class NSObjectInstanceTest {
    @Test func init_instance() {
        let classNSDictionary = NSObjectClass(name: "NSDictionary")!
        let dictionaryWithValuesForKeys = classNSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = classNSDictionary.instance(
            object: {
                let function = unsafeBitCast(
                    dictionaryWithValuesForKeys.implementation,
                    to: (@convention(c)(AnyClass, Selector, [String], [String])->[String: String]).self
                )
                return function(
                    dictionaryWithValuesForKeys.anyClass,
                    dictionaryWithValuesForKeys.selector,
                    ["1"],
                    ["a"]
                )
            }()
        )!
        
        #expect(instance.object.isKind(of: classNSDictionary.anyClass))
    }
}
