
//  ArrayStorage.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import SabyConcurrency
import Foundation

public protocol ArrayStorage<Value> {
    associatedtype Value
    
    func add(_ value: Value) -> Promise<UUID, Error>
    func delete(key: UUID) -> Promise<Void, Error>
    func clear() -> Promise<Void, Error>
    func get(key: UUID) -> Promise<Value?, Error>
    func get(limit: GetLimit) -> Promise<[Value], Error>
    func save() -> Promise<Void, Error>
}
