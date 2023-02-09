//
//  Promise.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

public final class Promise<Value> {
    var lock: UnsafeMutablePointer<pthread_mutex_t>
    var state: PromiseState<Value>
    
    let queue: DispatchQueue
    let executeGroup: DispatchGroup
    let cancelGroup: DispatchGroup
    
    init(queue: DispatchQueue = .global()) {
        self.lock = UnsafeMutablePointer.allocate(capacity: 1)
        lock.initialize(to: pthread_mutex_t())
        self.state = .pending
        
        self.queue = queue
        self.executeGroup = DispatchGroup()
        self.cancelGroup = DispatchGroup()
        
        executeGroup.enter()
        cancelGroup.enter()
        
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
        _ block: @escaping (
            _ resolve: @escaping (Value) -> Void,
            _ reject: @escaping (Error) -> Void
        ) throws -> Void
    ) {
        self.init(queue: queue)

        queue.async {
            do {
                try block({ self.resolve($0) }, { self.reject($0) })
            } catch let error {
                self.reject(error)
            }
        }
    }
    
    public convenience init(
        on queue: DispatchQueue = .global(),
        _ block: @escaping (
            _ resolve: @escaping (Value) -> Void,
            _ reject: @escaping (Error) -> Void,
            _ cancel: @escaping () -> Void,
            _ onCancel: @escaping (@escaping () -> Void) -> Void
        ) throws -> Void
    ) {
        self.init(queue: queue)

        queue.async {
            do {
                try block(
                    { self.resolve($0) },
                    { self.reject($0) },
                    { self.cancel() },
                    { self.subscribe(queue: queue, onCanceled: $0) }
                )
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
                    queue: queue,
                    onResolved: { self.resolve($0) },
                    onRejected: { self.reject($0) },
                    onCanceled: { self.cancel() }
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
            executeGroup.leave()
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func reject(_ error: Error) {
        pthread_mutex_lock(lock)
        
        if case .pending = state {
            state = .rejected(error)
            executeGroup.leave()
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func cancel() {
        pthread_mutex_lock(lock)
        
        if case .canceled = state {} else {
            state = .canceled
            cancelGroup.leave()
            if case .pending = state {
                executeGroup.leave()
            }
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func subscribe(
        queue: DispatchQueue,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Error) -> Void,
        onCanceled: @escaping () -> Void
    ) {
        executeGroup.notify(queue: queue) {
            pthread_mutex_lock(self.lock)
            let state = self.state
            pthread_mutex_unlock(self.lock)
            
            if case .resolved(let value) = state {
                onResolved(value)
            }
            else if case .rejected(let error) = state {
                onRejected(error)
            }
        }
        cancelGroup.notify(queue: queue) {
            pthread_mutex_lock(self.lock)
            let state = self.state
            pthread_mutex_unlock(self.lock)
            
            if case .canceled = state {
                onCanceled()
            }
        }
    }
    
    func subscribe(
        queue: DispatchQueue,
        onCanceled: @escaping () -> Void
    ) {
        cancelGroup.notify(queue: queue) {
            pthread_mutex_lock(self.lock)
            let state = self.state
            pthread_mutex_unlock(self.lock)
            
            if case .canceled = state {
                onCanceled()
            }
        }
    }
}

extension Promise {
    public func subscribe(
        on queue: DispatchQueue? = nil,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Error) -> Void,
        onCanceled: @escaping () -> Void
    ) {
        let queue = queue ?? self.queue
        
        subscribe(
            queue: queue,
            onResolved: onResolved,
            onRejected: onRejected,
            onCanceled: onCanceled
        )
    }
    
    public func subscribe(
        on queue: DispatchQueue? = nil,
        onCanceled: @escaping () -> Void
    ) {
        let queue = queue ?? self.queue
        
        subscribe(
            queue: queue,
            onCanceled: onCanceled
        )
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
    
    public var isCanceled: Bool {
        guard case .canceled = state else { return false }
        return true
    }
}

extension Promise {
    public static func pending(
        on queue: DispatchQueue = .global(),
        cancelWhen: PromisePending<Value>.CancelWhen = .none
    ) -> PromisePending<Value> {
        PromisePending(
            queue: queue,
            cancelWhen: cancelWhen
        )
    }
    
    public static func resolved(
        on queue: DispatchQueue = .global(),
        _ value: Value
    ) -> Promise<Value> {
        let promise = Promise(queue: queue)
        promise.state = .resolved(value)
        promise.executeGroup.leave()
        
        return promise
    }
    
    public static func rejected(
        on queue: DispatchQueue = .global(),
        _ error: Error
    ) -> Promise<Value> {
        let promise = Promise(queue: queue)
        promise.state = .rejected(error)
        promise.executeGroup.leave()
        
        return promise
    }
    
    public static func canceled(
        on queue: DispatchQueue = .global()
    ) -> Promise<Value> {
        let promise = Promise(queue: queue)
        promise.state = .canceled
        promise.executeGroup.leave()
        promise.cancelGroup.leave()
        
        return promise
    }
}

public final class PromisePending<Value> {
    public let promise: Promise<Value>
    public let resolve: (Value) -> Void
    public let reject: (Error) -> Void
    public let cancel: () -> Void
    public let onCancel: (@escaping () -> Void) -> Void
    
    let cancelWhen: CancelWhen
    
    init(
        queue: DispatchQueue,
        cancelWhen: CancelWhen
    ) {
        let promise = Promise<Value>(queue: queue)
        
        self.promise = promise
        self.resolve = { promise.resolve($0) }
        self.reject = { promise.reject($0) }
        self.cancel = { promise.cancel() }
        self.onCancel = { promise.subscribe(queue: queue, onCanceled: $0) }
        
        self.cancelWhen = cancelWhen
    }
    
    deinit {
        if case .deinit = cancelWhen {
            cancel()
        }
    }
    
    public enum CancelWhen {
        case `deinit`
        case none
    }
}

enum PromiseState<Value> {
    case pending
    case resolved(_ value: Value)
    case rejected(_ error: Error)
    case canceled
}

public enum PromiseError: Error {
    case timeout
}
