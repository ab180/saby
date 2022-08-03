//
//  ObjectDictionary.swift
//  SabyCollection
//
//  Created by 0xwof on 2022/08/03.
//

import Foundation

public struct ObjectDictionary<Key: AnyObject, Value> {
    var dictionary: Dictionary<ObjectIdentifier, Any> = [:]
    
    public init() {}
    
    public subscript(object: Key) -> Value? {
        get {
            dictionary[ObjectIdentifier(object)] as? Value
        }
        set(value) {
            dictionary[ObjectIdentifier(object)] = value
        }
    }
}
