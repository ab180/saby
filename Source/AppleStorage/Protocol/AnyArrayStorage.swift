//
//  AnyArrayStorage.swift
//  AppleStorage
//
//  Created by WOF on 2022/09/06.
//

import SabyConcurrency

extension ArrayStorage {
    @inline(__always) @inlinable
    public func toAnyArrayStorage() -> AnyArrayStorage<Value> {
        AnyArrayStorage(self)
    }
}

public struct AnyArrayStorage<Value: KeyIdentifiable>: ArrayStorage {
    @usableFromInline
    let arrayStorageBox: AnyArrayStorageBoxBase<Value>
    
    @inline(__always) @inlinable
    public init<ActualArrayStorage: ArrayStorage>(
        _ arrayStorage: ActualArrayStorage
    ) where ActualArrayStorage.Value == Value {
        if let anyArrayStorage = arrayStorage as? AnyArrayStorage<Value> {
            self.arrayStorageBox = anyArrayStorage.arrayStorageBox
        }
        else {
            self.arrayStorageBox = AnyArrayStorageBox(arrayStorage)
        }
    }
    
    @inline(__always) @inlinable
    public func push(_ value: Value) {
        arrayStorageBox.push(value)
    }
    
    @inline(__always) @inlinable
    public func delete(_ value: Value) {
        arrayStorageBox.delete(value)
    }
    
    @inline(__always) @inlinable
    public func get(key: Value.Key) -> Promise<Value> {
        arrayStorageBox.get(key: key)
    }
    
    @inline(__always) @inlinable
    public func get(limit: GetLimit) -> Promise<[Value]> {
        arrayStorageBox.get(limit: limit)
    }
    
    @inline(__always) @inlinable
    public func save() throws -> Promise<Void> {
        try arrayStorageBox.save()
    }
}

@usableFromInline
class AnyArrayStorageBoxBase<Value: KeyIdentifiable>: ArrayStorage {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func push(_ value: Value) {
        fatalError()
    }
    
    @inline(__always) @inlinable
    func delete(_ value: Value) {
        fatalError()
    }
    
    @inline(__always) @inlinable
    func get(key: Value.Key) -> Promise<Value> {
        fatalError()
    }
    
    @inline(__always) @inlinable
    func get(limit: GetLimit) -> Promise<[Value]> {
        fatalError()
    }
    
    @inline(__always) @inlinable
    func save() throws -> Promise<Void> {
        fatalError()
    }
}

@usableFromInline
final class AnyArrayStorageBox<
    ActualArrayStorage: ArrayStorage
>: AnyArrayStorageBoxBase<
    ActualArrayStorage.Value
> {
    @usableFromInline
    let arrayStorage: ActualArrayStorage
    
    @inline(__always) @inlinable
    init(_ ArrayStorage: ActualArrayStorage) {
        self.arrayStorage = ArrayStorage
    }
    
    @inline(__always) @inlinable
    override func push(_ value: Value) {
        arrayStorage.push(value)
    }
    
    @inline(__always) @inlinable
    override func delete(_ value: Value) {
        arrayStorage.delete(value)
    }
    
    @inline(__always) @inlinable
    override func get(key: Value.Key) -> Promise<Value> {
        arrayStorage.get(key: key)
    }
    
    @inline(__always) @inlinable
    override func get(limit: GetLimit) -> Promise<[Value]> {
        arrayStorage.get(limit: limit)
    }
    
    @inline(__always) @inlinable
    override func save() throws -> Promise<Void> {
        try arrayStorage.save()
    }
}
