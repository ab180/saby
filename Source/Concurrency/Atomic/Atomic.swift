//
//  Atomic.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/03.
//

import Foundation

public final class Atomic<Value> {
    @usableFromInline var value: Value
    @usableFromInline var token = pthread_mutex_t()

    public init(_ input: Value) {
        value = input
        
        pthread_mutex_init(&token, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&token)
    }

    @inlinable
    public var capture: Value {
        pthread_mutex_lock(&token)
        defer { pthread_mutex_unlock(&token) }
        
        return value
    }
    
    @inlinable
    public func use(_ block: (Value) -> Void) {
        pthread_mutex_lock(&token)
        defer { pthread_mutex_unlock(&token) }
        
        block(value)
    }
    
    @inlinable
    public func mutate(_ block: (Value) -> Value) {
        pthread_mutex_lock(&token)
        defer { pthread_mutex_unlock(&token) }
        
        value = block(value)
    }
}
