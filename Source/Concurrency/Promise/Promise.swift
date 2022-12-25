//
//  Promise.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

public final class Promise<Value> {
    var lock: UnsafeMutablePointer<pthread_mutex_t>
    var state: State
    
    let queue: DispatchQueue
    let group: DispatchGroup
    
    init(queue: DispatchQueue = .global()) {
        self.lock = UnsafeMutablePointer.allocate(capacity: 1)
        lock.initialize(to: pthread_mutex_t())
        self.state = .pending
        
        self.queue = queue
        self.group = DispatchGroup()
        
        group.enter()
        
        pthread_mutex_init(lock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(lock)
        
        lock.deallocate()
    }
}

extension Promise {
    public convenience init(
        on queue: DispatchQueue = .global(),
        _ work: @escaping (
            _ resolve: @escaping (Value) -> Void,
            _ reject: @escaping (Error) -> Void
        ) throws -> Void
    ) {
        self.init(queue: queue)

        queue.async {
            do {
                try work({ self.resolve($0) }, { self.reject($0) })
            } catch let error {
                self.reject(error)
            }
        }
    }
    
    public convenience init(
        on queue: DispatchQueue = .global(),
        _ block: @escaping () throws -> Value
    ) {
        self.init(queue: queue)

        queue.async {
            do {
                let value = try block()
                self.resolve(value)
            } catch let error {
                self.reject(error)
            }
        }
    }
    
    public convenience init(
        on queue: DispatchQueue = .global(),
        _ block: @escaping () throws -> Promise<Value>
    ) {
        self.init(queue: queue)
        
        queue.async {
            do {
                let promise = try block()
                promise.subscribe(
                    on: queue,
                    onResolved: { self.resolve($0) },
                    onRejected: { self.reject($0) }
                )
            } catch let error {
                self.reject(error)
            }
        }
    }
}

extension Promise {
    func resolve(_ value: Value) {
        pthread_mutex_lock(lock)
        
        if case .pending = state {
            state = .resolved(value)
            group.leave()
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func reject(_ error: Error) {
        pthread_mutex_lock(lock)
        
        if case .pending = state {
            state = .rejected(error)
            group.leave()
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func subscribe(
        on queue: DispatchQueue,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Error) -> Void
    ) {
        group.notify(queue: queue) {
            pthread_mutex_lock(self.lock)
            let state = self.state
            pthread_mutex_unlock(self.lock)
            
            switch state {
            case .resolved(let value):
                onResolved(value)
            case .rejected(let error):
                onRejected(error)
            case .pending:
                onRejected(InternalError.notifiedWhenPending)
            }
        }
    }
}

extension Promise {
    public var isPending: Bool {
        guard case .pending = state else { return false }
        return true
    }
    
    public var isResolved: Bool {
        guard case .resolved(_) = state else { return false }
        return true
    }
    
    public var isRejected: Bool {
        guard case .rejected(_) = state else { return false }
        return true
    }
}

extension Promise {
    public static func pending(
        on queue: DispatchQueue = .global()
    ) -> (
        Promise<Value>,
        Promise<Value>.Resolve,
        Promise<Value>.Reject
    ) {
        let promise = Promise(queue: queue)
        
        return (promise, { promise.resolve($0) }, { promise.reject($0) })
    }
    
    public static func resolved(
        on queue: DispatchQueue = .global(),
        _ value: Value
    ) -> Promise<Value> {
        let promise = Promise(queue: queue)
        promise.state = .resolved(value)
        promise.group.leave()
        
        return promise
    }
    
    public static func rejected(
        on queue: DispatchQueue = .global(),
        _ error: Error
    ) -> Promise<Value> {
        let promise = Promise(queue: queue)
        promise.state = .rejected(error)
        promise.group.leave()
        
        return promise
    }
}

extension Promise {
    enum State {
        case pending
        case resolved(_ value: Value)
        case rejected(_ error: Error)
    }
    
    public enum InternalError: Error {
        case timeout
        case resultOfAllHasWrongType
        case notifiedWhenPending
    }
}

extension Promise {
    public typealias Resolve = (Value) -> Void
    public typealias Reject = (Error) -> Void
}
