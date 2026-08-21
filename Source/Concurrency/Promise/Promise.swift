//
//  Promise.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

public final class Promise<
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
        state: PromiseState<Value, Failure>,
        observers: [@Sendable (PromiseState<Value, Failure>) -> Void]
    )

    init(
        queue: DispatchQueue = .global(),
        state: PromiseState<Value, Failure> = .pending
    ) {
        self.queue = queue
        self.storage = (state: state, observers: [])
    }

    fileprivate var callbacks: Callbacks {
        Callbacks(
            resolve: { [weak self] in self?.resolve($0) },
            reject: { [weak self] in self?.reject($0) },
            cancel: { [weak self] in self?.cancel() },
            onCancel: { [weak self] in self?.subscribe(onCanceled: $0) }
        )
    }
}

extension Promise {
    fileprivate convenience init(
        on queue: DispatchQueue,
        operation: @escaping @Sendable (
            Callbacks
        ) -> Void
    ) {
        self.init(queue: queue)

        let callbacks = self.callbacks

        queue.async { operation(callbacks) }
    }
}

extension Promise where Failure == Error {
    fileprivate convenience init(
        on queue: DispatchQueue,
        throwingOperation: @escaping @Sendable (
            Callbacks
        ) throws -> Void
    ) {
        self.init(on: queue, operation: { callbacks in
            do {
                try throwingOperation(callbacks)
            } catch {
                callbacks.reject(error)
            }
        })
    }

    public convenience init(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable (
            _ resolve: @escaping @Sendable (Value) -> Void,
            _ reject: @escaping @Sendable (Failure) -> Void
        ) throws -> Void
    ) {
        self.init(on: queue, throwingOperation: { try function($0.resolve, $0.reject) })
    }

    public convenience init(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable (
            _ resolve: @escaping @Sendable (Value) -> Void,
            _ reject: @escaping @Sendable (Failure) -> Void,
            _ cancel: @escaping @Sendable () -> Void,
            _ onCancel: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void
        ) throws -> Void
    ) {
        self.init(on: queue, throwingOperation: {
            try function(
                $0.resolve,
                $0.reject,
                $0.cancel,
                $0.onCancel
            )
        })
    }
}

extension Promise where Failure == Never {
    public convenience init(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable (
            _ resolve: @escaping @Sendable (Value) -> Void,
            _ reject: @escaping @Sendable (Failure) -> Void
        ) -> Void
    ) {
        self.init(on: queue, operation: { function($0.resolve, $0.reject) })
    }

    public convenience init(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable (
            _ resolve: @escaping @Sendable (Value) -> Void,
            _ reject: @escaping @Sendable (Failure) -> Void,
            _ cancel: @escaping @Sendable () -> Void,
            _ onCancel: @escaping @Sendable (@escaping @Sendable () -> Void) -> Void
        ) -> Void
    ) {
        self.init(on: queue, operation: {
            function(
                $0.resolve,
                $0.reject,
                $0.cancel,
                $0.onCancel
            )
        })
    }
}

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func async<Result: Sendable>(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable () async throws -> Result
    ) -> Promise<Result, Error> {
        Promise<Result, Error>(on: queue, operation: { callbacks in
            let task = Task {
                do {
                    callbacks.resolve(try await function())
                } catch {
                    callbacks.reject(error)
                }
            }

            callbacks.onCancel(task.cancel)
        })
    }

    public static func async<Result: Sendable>(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable () async -> Result
    ) -> Promise<Result, Never> {
        Promise<Result, Never>(on: queue, operation: { callbacks in
            let task = Task { callbacks.resolve(await function()) }
            callbacks.onCancel(task.cancel)
        })
    }

    public static func async<Result: Sendable>(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable () throws -> Result
    ) -> Promise<Result, Error> {
        Promise<Result, Error>(on: queue, throwingOperation: {
            $0.resolve(try function())
        })
    }

    public static func async<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable () throws -> Promise<Result, ResultFailure>
    ) -> Promise<Result, Error> {
        Promise<Result, Error>(on: queue, throwingOperation: { callbacks in
            let promise = try function()
            promise.subscribe(
                on: queue,
                onResolved: callbacks.resolve,
                onRejected: { callbacks.reject($0) },
                onCanceled: callbacks.cancel
            )
            callbacks.onCancel(promise.cancel)
        })
    }

    public static func async<Result: Sendable>(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable () -> Result
    ) -> Promise<Result, Never> {
        Promise<Result, Never>(on: queue, operation: { $0.resolve(function()) })
    }

    public static func async<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue = .global(),
        _ function: @escaping @Sendable () -> Promise<Result, ResultFailure>
    ) -> Promise<Result, ResultFailure> {
        Promise<Result, ResultFailure>(on: queue, operation: { callbacks in
            let promise = function()
            promise.subscribe(
                on: queue,
                onResolved: callbacks.resolve,
                onRejected: callbacks.reject,
                onCanceled: callbacks.cancel
            )
            callbacks.onCancel(promise.cancel)
        })
    }
}

extension Promise {
    func resolve(_ value: Value) { complete(with: .resolved(value)) }

    func reject(_ error: Failure) { complete(with: .rejected(error)) }

    func cancel() { complete(with: .canceled) }

    func capture() async -> PromiseState<Value, Failure> {
        lock.withLock { storage.state }
    }
}

extension Promise {
    public func subscribe(
        on queue: DispatchQueue? = nil,
        onResolved: @escaping @Sendable (Value) -> Void,
        onRejected: @escaping @Sendable (Failure) -> Void,
        onCanceled: @escaping @Sendable () -> Void
    ) {
        let queue = queue ?? self.queue

        observe { state in
            switch state {
            case .pending:
                break
            case .resolved(let value):
                queue.async { onResolved(value) }
            case .rejected(let error):
                queue.async { onRejected(error) }
            case .canceled:
                queue.async { onCanceled() }
            }
        }
    }

    public func subscribe(
        on queue: DispatchQueue? = nil,
        onCanceled: @escaping @Sendable () -> Void
    ) {
        let queue = queue ?? self.queue

        observe { state in
            guard state.isCanceled else { return }
            queue.async { onCanceled() }
        }
    }
}

extension Promise {
    public var isPending: Bool { get async { await capture().isPending } }

    public var isResolved: Bool { get async { await capture().isResolved } }

    public var isRejected: Bool { get async { await capture().isRejected } }

    public var isCanceled: Bool { get async { await capture().isCanceled } }
}

extension Promise {
    public static func pending(
        on queue: DispatchQueue = .global(),
        cancelWhen: PromisePendingCancelWhen = .none
    ) -> PromisePending<Value, Failure> {
        PromisePending(
            queue: queue,
            cancelWhen: cancelWhen
        )
    }

    public static func resolved(
        on queue: DispatchQueue = .global(),
        _ value: Value
    ) -> Promise<Value, Failure> {
        Promise(queue: queue, state: .resolved(value))
    }

    public static func rejected(
        on queue: DispatchQueue = .global(),
        _ error: Error
    ) -> Promise<Value, Error> where Failure == Error {
        Promise<Value, Error>(queue: queue, state: .rejected(error))
    }

    public static func canceled(
        on queue: DispatchQueue = .global()
    ) -> Promise<Value, Failure> {
        Promise(queue: queue, state: .canceled)
    }
}

public final class PromisePending<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    public let promise: Promise<Value, Failure>
    public let resolve: @Sendable (Value) -> Void
    public let reject: @Sendable (Failure) -> Void
    public let cancel: @Sendable () -> Void
    public let onCancel: @Sendable (@escaping @Sendable () -> Void) -> Void

    let cancelWhen: PromisePendingCancelWhen

    init(
        queue: DispatchQueue,
        cancelWhen: PromisePendingCancelWhen
    ) {
        let promise = Promise<Value, Failure>(queue: queue)
        let callbacks = promise.callbacks

        self.promise = promise
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
}

public enum PromisePendingCancelWhen: Sendable {
    case `deinit`
    case none
}

enum PromiseState<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    case pending
    case resolved(_ value: Value)
    case rejected(_ error: Failure)
    case canceled

    var isPending: Bool { if case .pending = self { true } else { false } }

    var isResolved: Bool { if case .resolved = self { true } else { false } }

    var isRejected: Bool { if case .rejected = self { true } else { false } }

    var isCanceled: Bool { if case .canceled = self { true } else { false } }
}

extension Promise {
    private func observe(
        _ observer: @escaping @Sendable (PromiseState<Value, Failure>) -> Void
    ) {
        lock.withLock {
            if storage.state.isPending {
                storage.observers.append(observer)
            } else {
                observer(storage.state)
            }
        }
    }

    private func complete(with state: PromiseState<Value, Failure>) {
        let observers = lock.withLock {
            guard storage.state.isPending else { return [] }

            storage.state = state
            let observers = storage.observers
            storage.observers.removeAll()
            observers.forEach { $0(state) }

            return observers
        }

        // Release observer captures after unlocking in case deinit reenters Promise.
        withExtendedLifetime(observers) {}
    }
}

public enum PromiseError: Error {
    case timeout
}
