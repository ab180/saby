
//  ArrayStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import SabyConcurrency

public protocol ArrayStorage<Value> {
    associatedtype Value: KeyIdentifiable
    
    func push(_ value: Value)
    func delete(_ value: Value)
    func get(key: Value.Key) -> Promise<Value?, Error>
    func get(limit: GetLimit) -> Promise<[Value], Error>
    func save() -> Promise<Void, Error>
}
