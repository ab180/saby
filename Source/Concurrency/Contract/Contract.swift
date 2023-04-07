//
//  Contract.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/10.
//

import Foundation

public final class Contract<Value, Failure: Error> {
    var lock: UnsafeMutablePointer<pthread_mutex_t>
    var state: ContractState
    
    let queue: DispatchQueue
    var executeGroup: DispatchGroup
    var cancelGroup: DispatchGroup

    var subscribers: [ContractSubscriber<Value, Failure>]
    
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
        pthread_mutex_lock(lock)
        if case .canceled = state {} else {
            cancelGroup.leave()
        }
        pthread_mutex_unlock(lock)
        
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

    func reject(_ error: Failure) {
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
        queue: DispatchQueue,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Failure) -> Void,
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

extension Contract {
    public func subscribe(
        on queue: DispatchQueue? = nil,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Failure) -> Void,
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

extension Contract {
    public var isExecuting: Bool {
        pthread_mutex_lock(self.lock)
        let state = self.state
        pthread_mutex_unlock(self.lock)

        guard case .executing = state else { return false }
        return true
    }
    
    public var isCanceled: Bool {
        pthread_mutex_lock(self.lock)
        let state = self.state
        pthread_mutex_unlock(self.lock)

        guard case .canceled = state else { return false }
        return true
    }
}

extension Contract {
    public static func executing(
        on queue: DispatchQueue = .global(),
        cancelWhen: ContractExecuting<Value, Failure>.CancelWhen = .none
    ) -> ContractExecuting<Value, Failure> {
        ContractExecuting(
            queue: queue,
            cancelWhen: cancelWhen
        )
    }
    
    public static func canceled(
        on queue: DispatchQueue = .global()
    ) -> Contract<Value, Failure> {
        let contract = Contract(queue: queue)
        contract.state = .canceled
        contract.cancelGroup.leave()
        
        return contract
    }
}

public final class ContractExecuting<Value, Failure: Error> {
    public let contract: Contract<Value, Failure>
    public let resolve: (Value) -> Void
    public let reject: (Failure) -> Void
    public let cancel: () -> Void
    public let onCancel: (@escaping () -> Void) -> Void
    
    let cancelWhen: CancelWhen
    
    init(
        queue: DispatchQueue,
        cancelWhen: CancelWhen
    ) {
        let contract = Contract<Value, Failure>(queue: queue)
        
        self.contract = contract
        self.resolve = { contract.resolve($0) }
        self.reject = { contract.reject($0) }
        self.cancel = { contract.cancel() }
        self.onCancel = { contract.subscribe(queue: queue, onCanceled: $0) }
        
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

enum ContractState {
    case executing
    case canceled
}

struct ContractSubscriber<Value, Failure: Error> {
    let queue: DispatchQueue
    let onResolved: (Value) -> Void
    let onRejected: (Failure) -> Void
}
