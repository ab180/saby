//
//  DictionaryStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import SabyConcurrency

public protocol DictionaryStorage<Key, Value>: Storage {
    associatedtype Key: Hashable
    associatedtype Value
    
    func set(key: Key, value: Value) -> Promise<Void, Error>
    func delete(key: Key) -> Promise<Void, Error>
    func clear() -> Promise<Void, Error>
    func get(key: Key) -> Promise<Value?, Error>
    func get(limit: Limit) -> Promise<[Value], Error>
    func save() -> Promise<Void, Error>
}
