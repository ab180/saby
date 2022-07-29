//
//  TypeDictionary.swift
//  SabyCollection
//
//  Created by WOF on 2022/07/29.
//

import Foundation

public struct TypeDictionary {
    var dictionary: Dictionary<ObjectIdentifier, Any> = [:]
    
    subscript<Value>(type: Value.Type) -> Value? {
        get {
            dictionary[ObjectIdentifier(type)] as? Value
        }
        set(value) {
            dictionary[ObjectIdentifier(type)] = value
        }
    }
}
