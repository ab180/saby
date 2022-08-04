//
//  TypeDictionary.swift
//  SabyCollection
//
//  Created by WOF on 2022/07/29.
//

import Foundation

public struct TypeDictionary<Value> {
    var dictionary: Dictionary<ObjectIdentifier, Value> = [:]
    
    public init() {}
    
    public subscript(type: Any.Type) -> Value? {
        get {
            dictionary[ObjectIdentifier(type)]
        }
        set(value) {
            dictionary[ObjectIdentifier(type)] = value
        }
    }
}
