//
//  Atomic.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/03.
//

import Foundation

public final class Atomic<Value> {
    @usableFromInline var lock: UnsafeMutablePointer<pthread_mutex_t>
    @usableFromInline var value: Value

    public init(_ input: Value) {
        self.lock = UnsafeMutablePointer.allocate(capacity: 1)
        lock.initialize(to: pthread_mutex_t())
        self.value = input
        
        pthread_mutex_init(lock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(lock)
        
        lock.deallocate()
    }
    
    @inline(__always) @inlinable
    @discardableResult
    public func capture<Result>(_ block: (Value) -> Result) -> Result {
        pthread_mutex_lock(lock)
        defer { pthread_mutex_unlock(lock) }
        
        return block(value)
    }
    
    @inline(__always) @inlinable
    @discardableResult
    public func mutate(_ block: (Value) -> Value) -> Value {
        pthread_mutex_lock(lock)
        defer { pthread_mutex_unlock(lock) }
        
        value = block(value)
        
        return value
    }
}
