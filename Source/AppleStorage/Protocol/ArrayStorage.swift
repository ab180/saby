
//  ArrayStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import SabyConcurrency

public protocol ArrayStorage {
    associatedtype Value: KeyIdentifiable
    
    func push(_ value: Value)
    func delete(_ value: Value)
    func get(key: Value.Key) -> Value?
    func get(limit: GetLimit) -> [Value]
    func save() -> Promise<Void>
}
