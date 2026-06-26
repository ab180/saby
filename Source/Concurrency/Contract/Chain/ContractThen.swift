//
//  ContractThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/14.
//

import Foundation

@available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private final class ContractThenTaskBag {
    private let state = Atomic(State())

    func insert(_ id: UUID, task: Task<Void, Never>) {
        var shouldCancel = false

        state.mutate { state in
            var state = state
            if state.isCanceled {
                shouldCancel = true
            }
            else if state.completedTaskIDs.contains(id) {
                state.completedTaskIDs.remove(id)
            }
            else {
                state.tasks[id] = task
            }
            return state
        }

        if shouldCancel {
            task.cancel()
        }
    }

    func remove(_ id: UUID) {
        state.mutate { state in
            var state = state
            if state.tasks.removeValue(forKey: id) == nil {
                state.completedTaskIDs.insert(id)
            }
            return state
        }
    }

    func cancelAll() {
        var tasks = [Task<Void, Never>]()

        state.mutate { state in
            var state = state
            state.isCanceled = true
            tasks = Array(state.tasks.values)
            state.tasks.removeAll()
            return state
        }

        tasks.forEach { $0.cancel() }
    }

    private struct State {
        var isCanceled = false
        var tasks = [UUID: Task<Void, Never>]()
        var completedTaskIDs = Set<UUID>()
    }
}

extension Contract {
    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) async throws -> Result
    ) -> Contract<Result, Error> {
        then(on: queue, schedule: .async, block)
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping (Value) async throws -> Result
    ) -> Contract<Result, Error> {
        let queue = queue ?? self.queue

        let contract = Contract<Result, Error>(queue: self.queue)
        let taskBag = ContractThenTaskBag()

        contract.subscribe(queue: queue) {
            taskBag.cancelAll()
        }

        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                guard contract.isExecuting else {
                    finish()
                    return
                }

                let taskID = UUID()
                let task = Task {
                    defer { finish() }
                    defer { taskBag.remove(taskID) }

                    do {
                        let result = try await block(value)
                        try Task.checkCancellation()
                        contract.resolve(result)
                    }
                    catch let error as CancellationError {
                        if Task.isCancelled {
                            contract.cancel()
                        }
                        else {
                            contract.reject(error)
                        }
                    }
                    catch let error {
                        contract.reject(error)
                    }
                }
                taskBag.insert(taskID, task: task)
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { [weak contract] in contract?.cancel() }
        )

        return contract
    }

    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Result
    ) -> Contract<Result, Error> {
        let queue = queue ?? self.queue

        let contract = Contract<Result, Error>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: { value in
                do {
                    let result = try block(value)
                    contract.resolve(result)
                }
                catch let error {
                    contract.reject(error)
                }
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { [weak contract] in contract?.cancel() }
        )

        return contract
    }

    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Promise<Result, ResultFailure>
    ) -> Contract<Result, Error> {
        then(on: queue, schedule: .async, block)
    }

    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping (Value) throws -> Promise<Result, ResultFailure>
    ) -> Contract<Result, Error> {
        let queue = queue ?? self.queue

        let contract = Contract<Result, Error>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                do {
                    let promise = try block(value)
                    promise.subscribe(
                        queue: queue,
                        onResolved: {
                            defer { finish() }
                            contract.resolve($0)
                        },
                        onRejected: {
                            defer { finish() }
                            contract.reject($0)
                        },
                        onCanceled: { [weak contract] in
                            defer { finish() }
                            contract?.cancel()
                        }
                    )
                }
                catch let error {
                    defer { finish() }
                    contract.reject(error)
                }
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { [weak contract] in contract?.cancel() }
        )

        return contract
    }
}

extension Contract where Failure == Never {
    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) async -> Result
    ) -> Contract<Result, Never> {
        then(on: queue, schedule: .async, block)
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping (Value) async -> Result
    ) -> Contract<Result, Never> {
        let queue = queue ?? self.queue

        let contract = Contract<Result, Never>(queue: self.queue)
        let taskBag = ContractThenTaskBag()

        contract.subscribe(queue: queue) {
            taskBag.cancelAll()
        }

        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                guard contract.isExecuting else {
                    finish()
                    return
                }

                let taskID = UUID()
                let task = Task {
                    defer { finish() }
                    defer { taskBag.remove(taskID) }

                    let result = await block(value)
                    guard !Task.isCancelled else {
                        contract.cancel()
                        return
                    }
                    contract.resolve(result)
                }
                taskBag.insert(taskID, task: task)
            },
            onRejected: { _ in },
            onCanceled: { [weak contract] in contract?.cancel() }
        )

        return contract
    }

    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Result
    ) -> Contract<Result, Never> {
        let queue = queue ?? self.queue

        let contract = Contract<Result, Never>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: { value in
                let result = block(value)
                contract.resolve(result)
            },
            onRejected: { _ in },
            onCanceled: { [weak contract] in contract?.cancel() }
        )

        return contract
    }

    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result, ResultFailure>
    ) -> Contract<Result, ResultFailure> {
        then(on: queue, schedule: .async, block)
    }

    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping (Value) -> Promise<Result, ResultFailure>
    ) -> Contract<Result, ResultFailure> {
        let queue = queue ?? self.queue

        let contract = Contract<Result, ResultFailure>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                let promise = block(value)
                promise.subscribe(
                    queue: queue,
                    onResolved: {
                        defer { finish() }
                        contract.resolve($0)
                    },
                    onRejected: {
                        defer { finish() }
                        contract.reject($0)
                    },
                    onCanceled: { [weak contract] in
                        defer { finish() }
                        contract?.cancel()
                    }
                )
            },
            onRejected: { _ in },
            onCanceled: { [weak contract] in contract?.cancel() }
        )

        return contract
    }
}
