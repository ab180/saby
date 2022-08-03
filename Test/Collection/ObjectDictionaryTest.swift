//
//  ObjectDictionaryTest.swift
//  SabyCollectionTest
//
//  Created by 0xwof on 2022/08/03.
//

import XCTest
@testable import SabyCollection

final class ObjectDictionaryTest: XCTestCase {
    func test__set_and_get() {
        var typeDictionary = ObjectDictionary<Object, Int>()
        
        let object1 = Object()
        let object2 = Object()
        
        typeDictionary[object1] = 10
        
        XCTAssertEqual(typeDictionary[object1], 10)
        XCTAssertEqual(typeDictionary[object2], nil)
    }
    
    private final class Object {}
}
