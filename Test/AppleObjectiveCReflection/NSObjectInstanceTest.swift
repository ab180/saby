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
        let NSDictionary = NSObjectClass(name: "NSDictionary")!
        let dictionaryWithValuesForKeys = NSDictionary.method(name: "dictionaryWithObjects:forKeys:")!
        let instance = NSDictionary.instance(
            object: NSDictionary.call(dictionaryWithValuesForKeys, with: ["1"], with: ["a"], return: .reference)
        )!
        
        XCTAssertTrue(instance.object.isKind(of: NSDictionary.anyClass))
    }
}
