//
//  Contract.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/10.
//

import Foundation

public final class Contract<Value> {
    var lock = pthread_mutex_t()
    
    let queue: DispatchQueue
    var subscribers: [Subscriber]
    
    init(queue: DispatchQueue = Contract<Void>.Setting.defaultQueue) {
        pthread_mutex_init(&lock, nil)
        
        self.queue = queue
        subscribers = []
    }
    
    deinit {
        pthread_mutex_destroy(&lock)
    }
}

extension Contract {
    public convenience init(on queue: DispatchQueue = Contract<Void>.Setting.defaultQueue) {
        self.init(queue: queue)
    }
}

extension Contract {
    public func resolve(_ value: Value) {
        pthread_mutex_lock(&lock)
        subscribers.forEach { $0.onResolved(value) }
        pthread_mutex_unlock(&lock)
    }

    public func reject(_ error: Error) {
        pthread_mutex_lock(&lock)
        subscribers.forEach { $0.onRejected(error) }
        pthread_mutex_unlock(&lock)
    }
}

extension Contract {
    func subscribe(subscriber: Subscriber) {
        pthread_mutex_lock(&lock)
        subscribers.append(subscriber)
        pthread_mutex_unlock(&lock)
    }
}

extension Contract {
    struct Subscriber {
        let onResolved: (Value) -> Void
        let onRejected: (Error) -> Void
        
        init(promiseAtomic: Atomic<Promise<Void>>,
             onResolved: @escaping (Value) -> Void,
             onRejected: @escaping (Error) -> Void)
        {
            self.onResolved = { value in
                promiseAtomic.mutate { promise in
                    promise = promise.then { onResolved(value) }
                }
            }
            self.onRejected = { error in
                promiseAtomic.use { promise in
                    promise.then { onRejected(error) }
                }
            }
        }
        
        init(on queue: DispatchQueue,
             onResolved: @escaping (Value) -> Void,
             onRejected: @escaping (Error) -> Void) {
            self.init(promiseAtomic: Atomic(Promise<Void>.resolved(on: queue, ())),
                      onResolved: onResolved,
                      onRejected: onRejected)
        }
        
        init(promiseAtomic: Atomic<Promise<Void>>,
             onResolved: @escaping (Value) -> Promise<Void>,
             onRejected: @escaping (Error) -> Promise<Void>)
        {
            self.onResolved = { value in
                promiseAtomic.mutate { promise in
                    promise = promise.then { onResolved(value) }
                }
            }
            self.onRejected = { error in
                promiseAtomic.use { promise in
                    promise.then { onRejected(error) }
                }
            }
        }
        
        init(on queue: DispatchQueue,
             onResolved: @escaping (Value) -> Promise<Void>,
             onRejected: @escaping (Error) -> Promise<Void>)
        {
            self.init(promiseAtomic: Atomic(Promise<Void>.resolved(on: queue, ())),
                      onResolved: onResolved,
                      onRejected: onRejected)
        }
    }
    
    public enum Setting where Value == Void {
        public static var defaultQueue: DispatchQueue {
            .global(qos: .default)
        }
    }
}
