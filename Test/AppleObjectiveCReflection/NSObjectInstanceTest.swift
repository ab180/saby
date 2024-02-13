//
//  NSObjectInstanceTest.swift
//  SabyAppleObjectiveCReflectionTest
//
//  Created by WOF on 2022/08/23.
//

import XCTest
@testable import SabyAppleObjectiveCReflection

final class NSObjectInstanceTest: XCTestCase {
    func test__init_instance() {
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
        
        XCTAssertTrue(instance.object.isKind(of: classNSDictionary.anyClass))
    }
}
