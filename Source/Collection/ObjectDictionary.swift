//
//  ObjectDictionary.swift
//  SabyCollection
//
//  Created by 0xwof on 2022/08/03.
//

import Foundation

public struct ObjectDictionary<Key: AnyObject, Value> {
    var dictionary: Dictionary<ObjectIdentifier, Value> = [:]
    
    public init() {}
    
    public subscript(object: Key) -> Value? {
        get {
            dictionary[ObjectIdentifier(object)]
        }
        set(value) {
            dictionary[ObjectIdentifier(object)] = value
        }
    }
}
