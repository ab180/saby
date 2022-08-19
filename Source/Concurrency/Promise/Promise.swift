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
    var subscribers: [Subscriber]
    
    init(queue: DispatchQueue = Promise<Void>.Setting.defaultQueue) {
        self.lock = UnsafeMutablePointer.allocate(capacity: 1)
        lock.initialize(to: pthread_mutex_t())
        self.state = .pending
        
        self.queue = queue
        self.subscribers = []
        
        pthread_mutex_init(lock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(lock)
        
        lock.deallocate()
    }
}

extension Promise {
    public convenience init(on queue: DispatchQueue = Promise<Void>.Setting.defaultQueue,
                            _ work: @escaping (_ resolve: @escaping (Value) -> Void,
                                               _ reject: @escaping (Error) -> Void) throws -> Void)
    {
        self.init(queue: queue)

        queue.async {
            do {
                try work({ self.resolve($0) }, { self.reject($0) })
            } catch let error {
                self.reject(error)
            }
        }
    }
    
    public convenience init(on queue: DispatchQueue = Promise<Void>.Setting.defaultQueue,
                            _ block: @escaping () throws -> Value)
    {
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
    
    public convenience init(on queue: DispatchQueue = Promise<Void>.Setting.defaultQueue,
                            _ block: @escaping () throws -> Promise<Value>)
    {
        self.init(queue: queue)
        
        queue.async {
            do {
                let promise = try block()
                promise.subscribe(subscriber: Subscriber(
                    on: queue,
                    onResolved: { self.resolve($0) },
                    onRejected: { self.reject($0) }
                ))
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
            subscribers.forEach { $0.onResolved(value) }
            subscribers = []
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func reject(_ error: Error) {
        pthread_mutex_lock(lock)
        
        if case .pending = state {
            state = .rejected(error)
            subscribers.forEach { $0.onRejected(error) }
            subscribers = []
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func subscribe(subscriber: Subscriber) {
        pthread_mutex_lock(lock)
        
        switch state {
        case .pending:
            subscribers.append(subscriber)
        case .resolved(let value):
            subscriber.onResolved(value)
        case .rejected(let error):
            subscriber.onRejected(error)
        }

        pthread_mutex_unlock(lock)
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
        on queue: DispatchQueue = Promise<Void>.Setting.defaultQueue
    ) -> (Promise<Value>, Promise<Value>.Resolve, Promise<Value>.Reject)
    {
        let promise = Promise(queue: queue)
        
        return (promise, { promise.resolve($0) }, { promise.reject($0) })
    }
    
    public static func resolved(on queue: DispatchQueue = Promise<Void>.Setting.defaultQueue,
                               _ value: Value) -> Promise<Value>
    {
        let promise = Promise(queue: queue)
        promise.state = .resolved(value)
        
        return promise
    }
    
    public static func rejected(on queue: DispatchQueue = Promise<Void>.Setting.defaultQueue,
                              _ error: Error) -> Promise<Value>
    {
        let promise = Promise(queue: queue)
        promise.state = .rejected(error)
        
        return promise
    }
}

extension Promise {
    struct Subscriber {
        let onResolved: (Value) -> Void
        let onRejected: (Error) -> Void
        
        init(on queue: DispatchQueue,
             onResolved: @escaping (Value) -> Void,
             onRejected: @escaping (Error) -> Void)
        {
            self.onResolved = { value in
                queue.async { onResolved(value) }
            }
            self.onRejected = { error in
                queue.async { onRejected(error) }
            }
        }
    }
    
    enum State {
        case pending
        case resolved(_ value: Value)
        case rejected(_ error: Error)
    }
    
    public enum Setting where Value == Void {
        public static var defaultQueue: DispatchQueue {
            .global(qos: .default)
        }
    }
    
    public enum InternalError: LocalizedError, CustomStringConvertible {
        case timeout
        case resultOfAllHasWrongType
        
        public var errorDescription: String {
            switch self {
            case .timeout:
                return "Promise exceed timeout"
            case .resultOfAllHasWrongType:
                return "Result of Promise all operation has wrong type"
            }
        }
        
        public var description: String {
            self.errorDescription
        }
    }
}

extension Promise {
    public typealias Resolve = (Value) -> Void
    public typealias Reject = (Error) -> Void
}
