//
//  Contract.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/10.
//

import Foundation

public final class Contract<Value> {
    var lock: UnsafeMutablePointer<pthread_mutex_t>
    var state: ContractState
    
    let queue: DispatchQueue
    var executeGroup: DispatchGroup
    var cancelGroup: DispatchGroup

    var subscribers: [ContractSubscriber<Value>]
    
    init(queue: DispatchQueue = .global()) {
        self.lock = UnsafeMutablePointer.allocate(capacity: 1)
        lock.initialize(to: pthread_mutex_t())
        self.state = .executing
        
        self.queue = queue
        self.executeGroup = DispatchGroup()
        self.cancelGroup = DispatchGroup()

        self.subscribers = []
        
        cancelGroup.enter()
        
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
        
        if case .executing = state {
            let current = executeGroup
            let next = DispatchGroup()
            let subscribers = subscribers
            
            subscribers.forEach { subscriber in
                next.enter()
                current.notify(queue: subscriber.queue) {
                    subscriber.onResolved(value)
                    next.leave()
                }
            }
            
            executeGroup = next
        }
        
        pthread_mutex_unlock(lock)
    }

    func reject(_ error: Error) {
        pthread_mutex_lock(lock)
        
        if case .executing = state {
            let current = executeGroup
            let next = DispatchGroup()
            let subscribers = subscribers
            
            subscribers.forEach { subscriber in
                next.enter()
                current.notify(queue: subscriber.queue) {
                    subscriber.onRejected(error)
                    next.leave()
                }
            }
            
            executeGroup = next
        }
        
        pthread_mutex_unlock(lock)
    }
    
    func cancel() {
        pthread_mutex_lock(lock)
        
        if case .canceled = state {} else {
            state = .canceled
            cancelGroup.leave()
        }
        
        pthread_mutex_unlock(lock)
    }

    func subscribe(
        on queue: DispatchQueue,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Error) -> Void,
        onCanceled: @escaping () -> Void
    ) {
        pthread_mutex_lock(lock)
        
        subscribers.append(ContractSubscriber(
            queue: queue,
            onResolved: onResolved,
            onRejected: onRejected)
        )
        
        pthread_mutex_unlock(lock)
        
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
        on queue: DispatchQueue,
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

extension Contract {
    public var isExecuting: Bool {
        guard case .executing = state else { return false }
        return true
    }
    
    public var isCanceled: Bool {
        guard case .canceled = state else { return false }
        return true
    }
}

extension Contract {
    public static func executing(
        on queue: DispatchQueue = .global()
    ) -> ContractExecuting<Value> {
        let contract = Contract(queue: queue)
        
        return ContractExecuting(
            contract: contract,
            resolve: { contract.resolve($0) },
            reject: { contract.reject($0) },
            onCancel: { contract.subscribe(on: queue, onCanceled: $0) }
        )
    }
}

public struct ContractExecuting<Value> {
    public let contract: Contract<Value>
    public let resolve: (Value) -> Void
    public let reject: (Error) -> Void
    public let onCancel: (@escaping () -> Void) -> Void
}

enum ContractState {
    case executing
    case canceled
}

struct ContractSubscriber<Value> {
    let queue: DispatchQueue
    let onResolved: (Value) -> Void
    let onRejected: (Error) -> Void
}
