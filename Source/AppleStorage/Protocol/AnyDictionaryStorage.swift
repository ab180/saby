//
//  AnyDictionaryStorage.swift
//  AppleStorage
//
//  Created by WOF on 2022/09/06.
//

import SabyConcurrency

extension DictionaryStorage {
    @inline(__always) @inlinable
    public func toAnyDictionaryStorage() -> AnyDictionaryStorage<Key, Value> {
        AnyDictionaryStorage(self)
    }
}

public struct AnyDictionaryStorage<
    Key: Hashable,
    Value
>: DictionaryStorage {
    @usableFromInline
    let dictionaryStorageBox: AnyDictionaryStorageBoxBase<Key, Value>
    
    @inline(__always) @inlinable
    public init<ActualDictionaryStorage: DictionaryStorage>(
        _ dictionaryStorage: ActualDictionaryStorage
    ) where
        ActualDictionaryStorage.Key == Key,
        ActualDictionaryStorage.Value == Value
    {
        if let anyDictionaryStorage = dictionaryStorage as? AnyDictionaryStorage<Key, Value> {
            self.dictionaryStorageBox = anyDictionaryStorage.dictionaryStorageBox
        }
        else {
            self.dictionaryStorageBox = AnyDictionaryStorageBox(dictionaryStorage)
        }
    }
    
    @inline(__always) @inlinable
    public func set(key: Key, value: Value) {
        dictionaryStorageBox.set(key: key, value: value)
    }
    
    @inline(__always) @inlinable
    public func delete(key: Key) {
        dictionaryStorageBox.delete(key: key)
    }
    
    @inline(__always) @inlinable
    public func get(key: Key) -> Value? {
        dictionaryStorageBox.get(key: key)
    }
    
    @inline(__always) @inlinable
    public func get(limit: GetLimit) -> [(Key, Value)] {
        dictionaryStorageBox.get(limit: limit)
    }
    
    @inline(__always) @inlinable
    public func save() -> Promise<Void> {
        dictionaryStorageBox.save()
    }
}

@usableFromInline
class AnyDictionaryStorageBoxBase<Key: Hashable, Value>: DictionaryStorage {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func set(key: Key, value: Value) {
        fatalError()
    }
    
    @inline(__always) @inlinable
    func delete(key: Key) {
        fatalError()
    }
    
    @inline(__always) @inlinable
    func get(key: Key) -> Value? {
        fatalError()
    }
    
    @inline(__always) @inlinable
    func get(limit: GetLimit) -> [(Key, Value)] {
        fatalError()
    }
    
    @inline(__always) @inlinable
    public func save() -> Promise<Void> {
        fatalError()
    }
}

@usableFromInline
final class AnyDictionaryStorageBox<
    ActualDictionaryStorage: DictionaryStorage
>: AnyDictionaryStorageBoxBase<
    ActualDictionaryStorage.Key,
    ActualDictionaryStorage.Value
> {
    @usableFromInline
    let dictionaryStorage: ActualDictionaryStorage
    
    @inline(__always) @inlinable
    init(_ DictionaryStorage: ActualDictionaryStorage) {
        self.dictionaryStorage = DictionaryStorage
    }
    
    @inline(__always) @inlinable
    override func set(key: Key, value: Value) {
        dictionaryStorage.set(key: key, value: value)
    }
    
    @inline(__always) @inlinable
    override func delete(key: Key) {
        dictionaryStorage.delete(key: key)
    }
    
    @inline(__always) @inlinable
    override func get(key: Key) -> Value? {
        dictionaryStorage.get(key: key)
    }
    
    @inline(__always) @inlinable
    override func get(limit: GetLimit) -> [(Key, Value)] {
        dictionaryStorage.get(limit: limit)
    }
    
    @inline(__always) @inlinable
    override func save() -> Promise<Void> {
        dictionaryStorage.save()
    }
}
