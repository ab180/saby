//
//  DictionaryStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import Foundation

public protocol DictionaryStorage {
    associatedtype Key: Hashable
    associatedtype Value
    
    func set(key: Key, value: Value)
    func delete(key: Key)
    func get(key: Key) -> Value
    func get(limit: GetLimit) -> [(Key, Value)]
}
