//
//  TypeDictionary.swift
//  SabyCollection
//
//  Created by WOF on 2022/07/29.
//

import Foundation

public struct TypeDictionary {
    var dictionary: Dictionary<ObjectIdentifier, Any> = [:]
    
    public init() {}
    
    public subscript<Value>(type: Value.Type) -> Value? {
        get {
            dictionary[ObjectIdentifier(type)] as? Value
        }
        set(value) {
            dictionary[ObjectIdentifier(type)] = value
        }
    }
    
    public func values() -> [Any] {
        dictionary.values.map { $0 }
    }
}
