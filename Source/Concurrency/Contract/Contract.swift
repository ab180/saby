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

    var subscribers: [ContractSubscriber<Value, Failure>]
    var cancelSubscribers: [ContractCancelSubscriber]
    
    init(queue: DispatchQueue = .global()) {
        self.state = Atomic(.executing)
        
        self.queue = queue
        self.executeGroup = DispatchGroup()

        self.subscribers = []
        self.cancelSubscribers = []
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
                    subscriber.onResolved.accept(
                        value,
                        after: current,
                        tracking: next
                    )
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
                    subscriber.onRejected.accept(
                        error,
                        after: current,
                        tracking: next
                    )
                }
                
                executeGroup = next
            }
        }
    }
    
    func cancel() {
        state.mutate { state in
            if case .executing = state {
                for cancelSubscriber in self.cancelSubscribers {
                    executeGroup.notify(queue: queue) {
                        cancelSubscriber.onCanceled()
                    }
                }
                subscribers = []
                cancelSubscribers = []
                return .canceled
            }
            
            return state
        }
    }

    func subscribe(
        queue: DispatchQueue,
        onResolved: ContractEventHandler<Value>,
        onRejected: ContractEventHandler<Failure>,
        onCanceled: @escaping () -> Void
    ) {
        state.capture { state in
            if case .executing = state {
                subscribers.append(ContractSubscriber(
                    onResolved: onResolved,
                    onRejected: onRejected
                ))
                cancelSubscribers.append(ContractCancelSubscriber(
                    queue: queue,
                    onCanceled: onCanceled
                ))
            }
            else if case .canceled = state {
                executeGroup.notify(queue: queue) {
                    onCanceled()
                }
            }
        }
    }

    func subscribe(
        queue: DispatchQueue,
        onResolved: @escaping (Value) -> Void,
        onRejected: @escaping (Failure) -> Void,
        onCanceled: @escaping () -> Void
    ) {
        subscribe(
            queue: queue,
            onResolved: ContractEventHandler(on: queue, block: onResolved),
            onRejected: ContractEventHandler(on: queue, block: onRejected),
            onCanceled: onCanceled
        )
    }

    func subscribe(
        queue: DispatchQueue,
        onResolved: ContractEventHandler<Value>,
        onRejected: @escaping (Failure) -> Void,
        onCanceled: @escaping () -> Void
    ) {
        subscribe(
            queue: queue,
            onResolved: onResolved,
            onRejected: ContractEventHandler(on: queue, block: onRejected),
            onCanceled: onCanceled
        )
    }

    func subscribe(
        queue: DispatchQueue,
        onResolved: @escaping (Value) -> Void,
        onRejected: ContractEventHandler<Failure>,
        onCanceled: @escaping () -> Void
    ) {
        subscribe(
            queue: queue,
            onResolved: ContractEventHandler(on: queue, block: onResolved),
            onRejected: onRejected,
            onCanceled: onCanceled
        )
    }
    
    func subscribe(
        queue: DispatchQueue,
        onCanceled: @escaping () -> Void
    ) {
        state.capture { state in
            if case .executing = state {
                cancelSubscribers.append(ContractCancelSubscriber(
                    queue: queue,
                    onCanceled: onCanceled
                ))
            }
            else if case .canceled = state {
                executeGroup.notify(queue: queue) {
                    onCanceled()
                }
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
    let subscribeQueue = DispatchQueue(label: "co.ab180.saby")
    
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

extension ContractExecuting {
    public func subscribe(
        _ contract: Contract<Value, Failure>
    ) {
        weak var weakSelf = self.contract
        contract.subscribe(
            on: subscribeQueue,
            onResolved: { weakSelf?.resolve($0) },
            onRejected: { weakSelf?.reject($0) },
            onCanceled: { weakSelf?.cancel() }
        )
    }
    
    public func subscribe(
        _ contracts: [Contract<Value, Failure>]
    ) {
        contracts.forEach {
            subscribe($0)
        }
    }
}

enum ContractState {
    case executing
    case canceled
}

struct ContractSubscriber<Value, Failure: Error> {
    let onResolved: ContractEventHandler<Value>
    let onRejected: ContractEventHandler<Failure>
}

struct ContractCancelSubscriber {
    let queue: DispatchQueue
    let onCanceled: () -> Void
}

struct ContractEventHandler<Value> {
    private let onAccepted: (
        Value,
        DispatchGroup,
        DispatchGroup
    ) -> Void

    init(
        on queue: DispatchQueue,
        block: @escaping (Value) -> Void
    ) {
        self.onAccepted = { value, previous, current in
            current.enter()
            previous.notify(queue: queue) {
                block(value)
                current.leave()
            }
        }
    }

    init(
        onAccepted: @escaping (
            Value,
            DispatchGroup,
            DispatchGroup
        ) -> Void
    ) {
        self.onAccepted = onAccepted
    }

    func accept(
        _ value: Value,
        after previous: DispatchGroup,
        tracking current: DispatchGroup
    ) {
        onAccepted(value, previous, current)
    }
}

public final class ContractSchedule {
    private let mode: Mode
    
    private init(mode: Mode) {
        self.mode = mode
    }
    
    func handler<Value>(
        on queue: DispatchQueue,
        sharesExplicitQueue: Bool,
        block: @escaping (
            Value,
            @escaping () -> Void
        ) -> Void
    ) -> ContractEventHandler<Value> {
        switch mode {
        case .async:
            return ContractEventHandler(on: queue) { value in
                block(value, {})
            }
        case .sync(let coordinator):
            guard sharesExplicitQueue else {
                return ContractEventHandler(on: queue) { value in
                    coordinator.enqueue(on: .global()) { finish in
                        block(value, finish)
                    }
                }
            }

            let coordinator = ContractScheduleCoordinatorRegistry.shared.coordinator(
                for: queue
            )
            return ContractEventHandler { value, previous, current in
                current.enter()
                coordinator.enqueue(on: queue) { finish in
                    previous.notify(queue: queue) {
                        block(value, finish)
                        current.leave()
                    }
                }
            }
        }
    }
    
    public static var async: ContractSchedule {
        self.init(mode: .async)
    }
    
    public static var sync: ContractSchedule {
        self.init(mode: .sync(coordinator: ContractScheduleCoordinator()))
    }
    
    private enum Mode {
        case async
        case sync(coordinator: ContractScheduleCoordinator)
    }
}

final class ContractScheduleCoordinator {
    private let tail = Atomic(Promise<Void, Never>.resolved(()))

    func enqueue(
        on queue: DispatchQueue,
        block: @escaping (@escaping () -> Void) -> Void
    ) {
        let completion = Promise<Void, Never>.pending()
        var previous: Promise<Void, Never>?

        tail.mutate { tail in
            previous = tail
            return completion.promise
        }

        let finish = { [self] in
            complete(completion)
        }

        previous?.subscribe(
            on: queue,
            onResolved: { _ in
                block(finish)
            },
            onRejected: { _ in },
            onCanceled: {
                block(finish)
            }
        )
    }

    private func complete(
        _ completion: PromisePending<Void, Never>
    ) {
        completion.resolve(())
    }
}

final class ContractScheduleCoordinatorRegistry {
    static let shared = ContractScheduleCoordinatorRegistry()

    private let entries = Atomic<[Entry]>([])

    private init() {}

    func coordinator(
        for queue: DispatchQueue
    ) -> ContractScheduleCoordinator {
        var result: ContractScheduleCoordinator?

        entries.mutate { entries in
            var entries = entries.filter {
                $0.queue != nil && $0.coordinator != nil
            }
            if let coordinator = entries.first(where: {
                $0.queue === queue
            })?.coordinator {
                result = coordinator
            }
            else {
                let coordinator = ContractScheduleCoordinator()
                entries.append(Entry(queue: queue, coordinator: coordinator))
                result = coordinator
            }
            return entries
        }

        return result!
    }

    var activeCount: Int {
        entries.mutate { entries in
            entries.filter {
                $0.queue != nil && $0.coordinator != nil
            }
        }.count
    }

    private final class Entry {
        weak var queue: DispatchQueue?
        weak var coordinator: ContractScheduleCoordinator?

        init(
            queue: DispatchQueue,
            coordinator: ContractScheduleCoordinator
        ) {
            self.queue = queue
            self.coordinator = coordinator
        }
    }
}
