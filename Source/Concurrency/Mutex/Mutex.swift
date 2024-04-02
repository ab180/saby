//
//  Mutex.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/08/25.
//

import Foundation

public final class Mutex {
    @usableFromInline var lock: UnsafeMutablePointer<pthread_mutex_t>

    public init() {
        self.lock = UnsafeMutablePointer.allocate(capacity: 1)
        lock.initialize(to: pthread_mutex_t())
        
        pthread_mutex_init(lock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(lock)
        
        lock.deinitialize(count: 1)
        lock.deallocate()
    }

    @inline(__always) @inlinable
    public func run(_ block: () -> Void) {
        pthread_mutex_lock(lock)
        defer { pthread_mutex_unlock(lock) }
        
        block()
    }
}
