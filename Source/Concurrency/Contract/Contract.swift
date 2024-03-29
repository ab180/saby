//
//  Contract.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/10.
//

import Foundation

public final class Contract<Value, Failure: Error> {
    var state: Atomic<ContractState>
    
    let queue: DispatchQueue
    var executeGroup: DispatchGroup
    var cancelGroup: DispatchGroup

    var subscribers: [ContractSubscriber<Value, Failure>]
    
    init(queue: DispatchQueue = .global()) {
        self.state = Atomic(.executing)
        
        self.queue = queue
        self.executeGroup = DispatchGroup()
        self.cancelGroup = DispatchGroup()

        self.subscribers = []
        
        cancelGroup.enter()
    }
    
    deinit {
        state.capture { state in
            if case .canceled = state {} else {
                cancelGroup.leave()
            }
        }
    }
}

extension Contract {
    func resolve(_ value: Value) {
        state.capture { state in
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
        }
    }

    func reject(_ error: Failure) {
        state.capture { state in
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
        }
    }
    
    func cancel() {
        state.mutate { state in
            if case .canceled = state {} else {
                cancelGroup.leave()
                return .canceled
            }
            
            return state
        }
    }

    func subscribe(
        queue: DispatchQueue,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Failure) -> Void,
        onCanceled: @escaping () -> Void
    ) {
        state.capture { state in
            subscribers.append(ContractSubscriber(
                queue: queue,
                onResolved: onResolved,
                onRejected: onRejected
            ))
        }
        
        let state = self.state
        cancelGroup.notify(queue: queue) {
            let state = state.capture { $0 }
            
            if case .canceled = state {
                onCanceled()
            }
        }
    }
    
    func subscribe(
        queue: DispatchQueue,
        onCanceled: @escaping () -> Void
    ) {
        let state = self.state
        cancelGroup.notify(queue: queue) {
            let state = state.capture { $0 }
            
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
        let state = state.capture { $0 }

        guard case .executing = state else { return false }
        return true
    }
    
    public var isCanceled: Bool {
        let state = state.capture { $0 }

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
        contract.state = Atomic(.canceled)
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

public final class ContractSchedule {
    private let mode: Mode
    
    private init(mode: Mode) {
        self.mode = mode
    }
    
    func callAsFunction<Value>(
        block: @escaping (
            Value,
            @escaping () -> Void
        ) -> Void
    ) -> (Value) -> Void {
        switch mode {
        case .async:
            return { value in
                block(value, {})
            }
        case .sync(let next):
            return { value in
                next.mutate { promise in
                    promise.then { _ in
                        Promise { resolve, _ in
                            block(value, { resolve(()) })
                        }
                    }
                }
            }
        }
    }
    
    public static var async: ContractSchedule {
        self.init(mode: .async)
    }
    
    public static var sync: ContractSchedule {
        self.init(mode: .sync(next: Atomic(.resolved(()))))
    }
    
    private enum Mode {
        case async
        case sync(next: Atomic<Promise<Void, Never>>)
    }
}
