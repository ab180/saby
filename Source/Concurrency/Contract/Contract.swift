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
    let state: ContractStateActor<Value, Failure>
    private let events: AsyncStream<ContractEvent<Value, Failure>>.Continuation

    let queue: DispatchQueue

    init(
        queue: DispatchQueue = .global(),
        state: ContractState = .executing
    ) {
        let stateActor = ContractStateActor<Value, Failure>(
            state: state,
            queue: queue
        )
        let (eventStream, events) = AsyncStream.makeStream(
            of: ContractEvent<Value, Failure>.self
        )

        self.state = stateActor
        self.events = events
        self.queue = queue

        Task {
            for await event in eventStream {
                await stateActor.receive(event)
            }
        }
    }

    deinit {
        events.finish()
    }
}

extension Contract {
    func resolve(_ value: Value) {
        events.yield(.resolve(value))
    }

    func reject(_ error: Failure) {
        events.yield(.reject(error))
    }

    func cancel() {
        events.yield(.cancel)
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
        let cancelSubscriber = ContractCancelSubscriber(
            queue: queue,
            onCanceled: onCanceled
        )
        events.yield(.subscribe(
            subscriber,
            cancelSubscriber: cancelSubscriber
        ))
    }

    func subscribe(
        queue: DispatchQueue,
        onCanceled: @escaping @Sendable () -> Void
    ) {
        let subscriber = ContractCancelSubscriber(
            queue: queue,
            onCanceled: onCanceled
        )
        events.yield(.subscribeCancel(subscriber))
    }

    func capture() async -> ContractState {
        await withCheckedContinuation { continuation in
            events.yield(.capture(continuation))
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
        get async {
            await capture().isExecuting
        }
    }

    public var isCanceled: Bool {
        get async {
            await capture().isCanceled
        }
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
    var isExecuting: Bool {
        guard case .executing = self else { return false }
        return true
    }

    var isCanceled: Bool {
        guard case .canceled = self else { return false }
        return true
    }
}

actor ContractStateActor<
    Value: Sendable,
    Failure: Error & Sendable
> {
    private var state: ContractState
    private let queue: DispatchQueue
    private var executeGroup = DispatchGroup()
    private var subscribers: [ContractSubscriber<Value, Failure>] = []
    private var cancelSubscribers: [ContractCancelSubscriber] = []

    init(
        state: ContractState,
        queue: DispatchQueue
    ) {
        self.state = state
        self.queue = queue
    }

    func subscriberCount() -> Int {
        subscribers.count
    }

    func receive(_ event: ContractEvent<Value, Failure>) {
        switch event {
        case .resolve(let value):
            resolve(value)
        case .reject(let error):
            reject(error)
        case .cancel:
            cancel()
        case .subscribe(let subscriber, let cancelSubscriber):
            subscribe(
                subscriber,
                cancelSubscriber: cancelSubscriber
            )
        case .subscribeCancel(let subscriber):
            subscribe(subscriber)
        case .capture(let continuation):
            continuation.resume(returning: state)
        }
    }

    private func resolve(_ value: Value) {
        guard case .executing = state else { return }

        let current = executeGroup
        let next = DispatchGroup()
        let subscribers = self.subscribers

        subscribers.forEach { subscriber in
            next.enter()
            current.notify(queue: subscriber.queue) {
                subscriber.onResolved(value)
                next.leave()
            }
        }

        executeGroup = next
    }

    private func reject(_ error: Failure) {
        guard case .executing = state else { return }

        let current = executeGroup
        let next = DispatchGroup()
        let subscribers = self.subscribers

        subscribers.forEach { subscriber in
            next.enter()
            current.notify(queue: subscriber.queue) {
                subscriber.onRejected(error)
                next.leave()
            }
        }

        executeGroup = next
    }

    private func cancel() {
        guard case .executing = state else { return }

        state = .canceled

        let current = executeGroup
        let queue = self.queue
        let cancelSubscribers = self.cancelSubscribers
        subscribers.removeAll()
        self.cancelSubscribers.removeAll()

        cancelSubscribers.forEach { subscriber in
            current.notify(queue: queue) {
                subscriber.onCanceled()
            }
        }
    }

    private func subscribe(
        _ subscriber: ContractSubscriber<Value, Failure>,
        cancelSubscriber: ContractCancelSubscriber
    ) {
        switch state {
        case .executing:
            subscribers.append(subscriber)
            cancelSubscribers.append(cancelSubscriber)
        case .canceled:
            executeGroup.notify(queue: cancelSubscriber.queue) {
                cancelSubscriber.onCanceled()
            }
        }
    }

    private func subscribe(_ subscriber: ContractCancelSubscriber) {
        switch state {
        case .executing:
            cancelSubscribers.append(subscriber)
        case .canceled:
            executeGroup.notify(queue: subscriber.queue) {
                subscriber.onCanceled()
            }
        }
    }
}

enum ContractEvent<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    case resolve(Value)
    case reject(Failure)
    case cancel
    case subscribe(
        ContractSubscriber<Value, Failure>,
        cancelSubscriber: ContractCancelSubscriber
    )
    case subscribeCancel(ContractCancelSubscriber)
    case capture(CheckedContinuation<ContractState, Never>)
}

struct ContractSubscriber<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    let queue: DispatchQueue
    let onResolved: @Sendable (Value) -> Void
    let onRejected: @Sendable (Failure) -> Void
}

struct ContractCancelSubscriber: Sendable {
    let queue: DispatchQueue
    let onCanceled: @Sendable () -> Void
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
            return { value in
                block(value, {})
            }
        case .sync(let state):
            return { value in
                state.schedule { finish in
                    block(value, finish)
                }
            }
        }
    }

    public static var async: ContractSchedule {
        self.init(mode: .async)
    }

    public static var sync: ContractSchedule {
        self.init(mode: .sync(state: ContractScheduleState()))
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

    private let operations: AsyncStream<Operation>.Continuation

    init() {
        let (operationStream, operations) = AsyncStream.makeStream(
            of: Operation.self
        )
        self.operations = operations

        Task {
            var next = Promise<Void, Never>.resolved(())

            for await operation in operationStream {
                next = next.then { _ in
                    Promise { resolve, _ in
                        operation { resolve(()) }
                    }
                }
            }
        }
    }

    deinit {
        operations.finish()
    }

    fileprivate func schedule(
        _ operation: @escaping Operation
    ) {
        operations.yield(operation)
    }
}
