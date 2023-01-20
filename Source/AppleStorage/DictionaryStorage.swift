//
//  DictionaryStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import SabyConcurrency

public protocol DictionaryStorage<Key, Value> {
    associatedtype Key: Hashable
    associatedtype Value
    
    var keys: Dictionary<Key, Value>.Keys { get }
    var values: Dictionary<Key, Value>.Values { get }
    
    func set(key: Key, value: Value)
    func delete(key: Key)
    func get(key: Key) -> Value?
    func save() -> Promise<Void>
}
