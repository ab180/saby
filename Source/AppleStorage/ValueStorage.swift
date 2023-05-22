//
//  ValueStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2023/02/23.
//

import SabyConcurrency

public protocol ValueStorage<Value> {
    associatedtype Value
    
    func set(_ value: Value) -> Promise<Void, Error>
    func clear() -> Promise<Void, Error>
    func get() -> Promise<Value?, Error>
    func save() -> Promise<Void, Error>
}
