//
//  Contract.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/10.
//

import Foundation

public final class Contract<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    fileprivate struct Callbacks: Sendable {
        let resolve: @Sendable (Value) -> Void
        let reject: @Sendable (Failure) -> Void
        let cancel: @Sendable () -> Void
        let onCancel: @Sendable (@escaping @Sendable () -> Void) -> Void
    }

    let queue: DispatchQueue
    private let lock = NSLock()
    nonisolated(unsafe) private var storage: (
        state: ContractState,
        executeGroup: DispatchGroup,
        subscribers: [ContractSubscriber<Value, Failure>],
        cancelSubscribers: [@Sendable () -> Void]
    )

    init(
        queue: DispatchQueue = .global(),
        state: ContractState = .executing
    ) {
        self.queue = queue
        self.storage = (
            state: state,
            executeGroup: DispatchGroup(),
            subscribers: [],
            cancelSubscribers: []
        )
    }

    fileprivate var callbacks: Callbacks {
        Callbacks(
            resolve: { [self] in resolve($0) },
            reject: { [self] in reject($0) },
            cancel: { [self] in cancel() },
            onCancel: { [self] in subscribe(onCanceled: $0) }
        )
    }
}

extension Contract {
    func resolve(_ value: Value) {
        emit { $0.onResolved(value) }
    }

    func reject(_ error: Failure) {
        emit { $0.onRejected(error) }
    }

    func cancel() {
        let cancellation: (
            executeGroup: DispatchGroup,
            subscribers: [ContractSubscriber<Value, Failure>],
            cancelSubscribers: [@Sendable () -> Void]
        )? = lock.withLock {
            guard storage.state.isExecuting else { return nil }

            storage.state = .canceled

            let cancellation = (
                executeGroup: storage.executeGroup,
                subscribers: storage.subscribers,
                cancelSubscribers: storage.cancelSubscribers
            )
            storage.subscribers.removeAll()
            storage.cancelSubscribers.removeAll()
            return cancellation
        }

        guard var cancellation else { return }

        cancellation.subscribers.removeAll()

        cancellation.cancelSubscribers.forEach { onCanceled in
            cancellation.executeGroup.notify(queue: queue) {
                onCanceled()
            }
        }
    }

    func subscribe(
        queue: DispatchQueue,
        onResolved: @escaping @Sendable (Value) -> Void,
        onRejected: @escaping @Sendable (Failure) -> Void,
        onCanceled: @escaping @Sendable () -> Void
    ) {
        let subscriber = ContractSubscriber(
            queue: queue,
            onResolved: onResolved,
            onRejected: onRejected
        )
        let canceledGroup: DispatchGroup? = lock.withLock {
            switch storage.state {
            case .executing:
                storage.subscribers.append(subscriber)
                storage.cancelSubscribers.append(onCanceled)
                return nil
            case .canceled:
                return storage.executeGroup
            }
        }

        canceledGroup?.notify(queue: queue) {
            onCanceled()
        }
    }

    func subscribe(
        queue: DispatchQueue,
        onCanceled: @escaping @Sendable () -> Void
    ) {
        let canceledGroup: DispatchGroup? = lock.withLock {
            switch storage.state {
            case .executing:
                storage.cancelSubscribers.append(onCanceled)
                return nil
            case .canceled:
                return storage.executeGroup
            }
        }

        canceledGroup?.notify(queue: queue) {
            onCanceled()
        }
    }

    private func emit(
        _ callback: @escaping @Sendable (
            ContractSubscriber<Value, Failure>
        ) -> Void
    ) {
        let delivery: (
            current: DispatchGroup,
            next: DispatchGroup,
            subscribers: [ContractSubscriber<Value, Failure>]
        )? = lock.withLock {
            guard storage.state.isExecuting else { return nil }

            let current = storage.executeGroup
            let next = DispatchGroup()
            let subscribers = storage.subscribers
            subscribers.forEach { _ in next.enter() }
            storage.executeGroup = next
            return (
                current: current,
                next: next,
                subscribers: subscribers
            )
        }

        guard let delivery else { return }

        delivery.subscribers.forEach { subscriber in
            delivery.current.notify(queue: subscriber.queue) {
                defer { delivery.next.leave() }
                callback(subscriber)
            }
        }
    }
}

extension Contract {
    public func subscribe(
        on queue: DispatchQueue? = nil,
        onResolved: @escaping @Sendable (Value) -> Void,
        onRejected: @escaping @Sendable (Failure) -> Void,
        onCanceled: @escaping @Sendable () -> Void
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
        onCanceled: @escaping @Sendable () -> Void
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
        get async { lock.withLock { storage.state.isExecuting } }
    }

    public var isCanceled: Bool {
        get async { lock.withLock { storage.state.isCanceled } }
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
        Contract(queue: queue, state: .canceled)
    }
}

public final class ContractExecuting<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    public let contract: Contract<Value, Failure>
    public let resolve: @Sendable (Value) -> Void
    public let reject: @Sendable (Failure) -> Void
    public let cancel: @Sendable () -> Void
    public let onCancel: @Sendable (@escaping @Sendable () -> Void) -> Void

    let cancelWhen: CancelWhen
    let subscribeQueue = DispatchQueue(label: "co.ab180.saby")

    init(
        queue: DispatchQueue,
        cancelWhen: CancelWhen
    ) {
        let contract = Contract<Value, Failure>(queue: queue)
        let callbacks = contract.callbacks

        self.contract = contract
        self.resolve = callbacks.resolve
        self.reject = callbacks.reject
        self.cancel = callbacks.cancel
        self.onCancel = callbacks.onCancel

        self.cancelWhen = cancelWhen
    }

    deinit {
        if case .deinit = cancelWhen {
            cancel()
        }
    }

    public enum CancelWhen: Sendable {
        case `deinit`
        case none
    }
}

extension ContractExecuting {
    public func subscribe(
        _ contract: Contract<Value, Failure>
    ) {
        weak let weakSelf = self.contract
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

enum ContractState: Sendable {
    case executing
    case canceled
}

extension ContractState {
    var isExecuting: Bool { if case .executing = self { true } else { false } }

    var isCanceled: Bool { if case .canceled = self { true } else { false } }
}

struct ContractSubscriber<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    let queue: DispatchQueue
    let onResolved: @Sendable (Value) -> Void
    let onRejected: @Sendable (Failure) -> Void
}

public final class ContractSchedule: Sendable {
    private let mode: Mode

    private init(mode: Mode) {
        self.mode = mode
    }

    func callAsFunction<Value: Sendable>(
        block: @escaping @Sendable (
            Value,
            @escaping @Sendable () -> Void
        ) -> Void
    ) -> @Sendable (Value) -> Void {
        switch mode {
        case .async:
            return { block($0, {}) }
        case .sync(let state):
            return { value in
                state.schedule { block(value, $0) }
            }
        }
    }

    public static var async: ContractSchedule { .init(mode: .async) }

    public static var sync: ContractSchedule {
        .init(mode: .sync(state: ContractScheduleState()))
    }

    private enum Mode: Sendable {
        case async
        case sync(state: ContractScheduleState)
    }
}

fileprivate final class ContractScheduleState: Sendable {
    fileprivate typealias Operation = @Sendable (
        @escaping @Sendable () -> Void
    ) -> Void

    private let lock = NSLock()
    nonisolated(unsafe) private var next = Promise<Void, Never>.resolved(())

    fileprivate func schedule(
        _ operation: @escaping Operation
    ) {
        lock.withLock {
            next = next.then { _ in
                Promise { resolve, _ in
                    operation { resolve(()) }
                }
            }
        }
    }
}
