//
//  PromiseThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) async throws -> Result
    ) -> Promise<Result, Error> {
        let queue = queue ?? self.queue

        let promiseReturn = Promise<Result, Error>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: { value in
                guard promiseReturn.isPending else { return }

                let task = Task {
                    do {
                        let value = try await block(value)
                        try Task.checkCancellation()
                        promiseReturn.resolve(value)
                    }
                    catch let error as CancellationError {
                        if Task.isCancelled {
                            promiseReturn.cancel()
                        }
                        else {
                            promiseReturn.reject(error)
                        }
                    }
                    catch let error {
                        promiseReturn.reject(error)
                    }
                }
                promiseReturn.subscribe(queue: queue) {
                    task.cancel()
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )

        return promiseReturn
    }

    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Result
    ) -> Promise<Result, Error> {
        let queue = queue ?? self.queue

        let promiseReturn = Promise<Result, Error>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: {
                do {
                    let value = try block($0)
                    promiseReturn.resolve(value)
                }
                catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )

        return promiseReturn
    }

    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Promise<Result, ResultFailure>
    ) -> Promise<Result, Error> {
        let queue = queue ?? self.queue

        let promiseReturn = Promise<Result, Error>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: {
                do {
                    let promise = try block($0)
                    promise.subscribe(
                        queue: queue,
                        onResolved: { promiseReturn.resolve($0) },
                        onRejected: { promiseReturn.reject($0) },
                        onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
                    )
                }
                catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )

        return promiseReturn
    }
}

extension Promise where Failure == Never {
    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) async -> Result
    ) -> Promise<Result, Never> {
        let queue = queue ?? self.queue

        let promiseReturn = Promise<Result, Never>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: { value in
                guard promiseReturn.isPending else { return }

                let task = Task {
                    let value = await block(value)
                    guard !Task.isCancelled else {
                        promiseReturn.cancel()
                        return
                    }
                    promiseReturn.resolve(value)
                }
                promiseReturn.subscribe(queue: queue) {
                    task.cancel()
                }
            },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )

        return promiseReturn
    }

    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Result
    ) -> Promise<Result, Never> {
        let queue = queue ?? self.queue

        let promiseReturn = Promise<Result, Never>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: {
                let value = block($0)
                promiseReturn.resolve(value)
            },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )

        return promiseReturn
    }

    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result, ResultFailure>
    ) -> Promise<Result, ResultFailure> {
        let queue = queue ?? self.queue

        let promiseReturn = Promise<Result, ResultFailure>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: {
                let promise = block($0)
                promise.subscribe(
                    queue: queue,
                    onResolved: { promiseReturn.resolve($0) },
                    onRejected: { promiseReturn.reject($0) },
                    onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
                )
            },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )

        return promiseReturn
    }
}
