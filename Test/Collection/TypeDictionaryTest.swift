//
//  TypeDictionary.swift
//  SabyCollectionTest
//
//  Created by WOF on 2022/07/29.
//

import XCTest
@testable import SabyCollection

final class TypeDictionaryTest: XCTestCase {
    func test__set_and_get() {
        var typeDictionary = TypeDictionary()
        
        typeDictionary[Int.self] = 10
        
        XCTAssertEqual(typeDictionary[Int.self], 10)
    }
}
