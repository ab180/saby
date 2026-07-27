//
//  SetStorage.swift
//  SabyAppleStorage
//

import SabyConcurrency
import SabySize

public protocol SetStorage<Value>: Storage {
    associatedtype Value: Hashable

    func set(_ values: Set<Value>) -> Promise<Void, Error>
    func add(_ value: Value) -> Promise<Void, Error>
    func delete(_ value: Value) -> Promise<Void, Error>
    func get() -> Promise<Set<Value>, Error>
    func contains(_ value: Value) -> Promise<Bool, Error>
    func clear() -> Promise<Void, Error>

    func count() -> Promise<Int, Error>
    func size() -> Promise<Volume, Error>
}
