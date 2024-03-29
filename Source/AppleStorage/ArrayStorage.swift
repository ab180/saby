
//  ArrayStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import SabyConcurrency
import SabySize
import Foundation

public protocol ArrayStorage<Value>: Storage {
    associatedtype Value: KeyIdentifiable
    
    func add(_ value: Value) -> Promise<Void, Error>
    func add(_ values: [Value]) -> Promise<Void, Error>
    func delete(key: UUID) -> Promise<Void, Error>
    func delete(keys: [UUID]) -> Promise<Void, Error>
    func clear() -> Promise<Void, Error>
    func get(key: UUID) -> Promise<Value?, Error>
    func get(limit: Limit) -> Promise<[Value], Error>
    func get(limit: Limit, order: Order) -> Promise<[Value], Error>
    func save() -> Promise<Void, Error>
    
    func count() -> Promise<Int, Error>
    func size() -> Promise<Volume, Error>
}
