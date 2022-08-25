//
//  Lock.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/08/25.
//

import Foundation

public final class Lock {
    @usableFromInline var token: UnsafeMutablePointer<pthread_mutex_t>

    public init() {
        self.token = UnsafeMutablePointer.allocate(capacity: 1)
        token.initialize(to: pthread_mutex_t())
        
        pthread_mutex_init(token, nil)
    }
    
    deinit {
        pthread_mutex_destroy(token)
        
        token.deallocate()
    }

    @inline(__always) @inlinable
    public func lock() {
        pthread_mutex_lock(token)
    }
    
    @inline(__always) @inlinable
    public func unlock() {
        pthread_mutex_unlock(token)
    }
}
