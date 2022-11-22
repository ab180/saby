//
//  Contract.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/10.
//

import Foundation

public final class Contract<Value> {
    var lock: UnsafeMutablePointer<pthread_mutex_t>
    
    let queue: DispatchQueue
    var subscribers: [Subscriber]
    
    init(queue: DispatchQueue = .global()) {
        self.lock = UnsafeMutablePointer.allocate(capacity: 1)
        lock.initialize(to: pthread_mutex_t())
        
        self.queue = queue
        self.subscribers = []
        
        pthread_mutex_init(lock, nil)
    }
    
    deinit {
        pthread_mutex_destroy(lock)
        
        lock.deallocate()
    }
}

extension Contract {
    func resolve(_ value: Value) {
        pthread_mutex_lock(lock)
        subscribers.forEach { $0.onResolved(value) }
        pthread_mutex_unlock(lock)
    }

    func reject(_ error: Error) {
        pthread_mutex_lock(lock)
        subscribers.forEach { $0.onRejected(error) }
        pthread_mutex_unlock(lock)
    }

    func subscribe(subscriber: Subscriber) {
        pthread_mutex_lock(lock)
        subscribers.append(subscriber)
        pthread_mutex_unlock(lock)
    }
}

extension Contract {
    public static func create(
        on queue: DispatchQueue = .global()
    ) -> (Contract<Value>, (Value) -> Void, (Error) -> Void)
    {
        let contract = Contract(queue: queue)
        
        return (contract, { contract.resolve($0) }, { contract.reject($0) })
    }
    
    public convenience init(on queue: DispatchQueue = .global()) {
        self.init(queue: queue)
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
                    promise.then { onResolved(value) }
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
    }
}
