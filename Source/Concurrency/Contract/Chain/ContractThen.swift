//
//  ContractThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/14.
//

import Foundation

extension Contract {
    @discardableResult
    public func then<Result: Sendable>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) throws -> Result
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
    public func then<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) throws -> Promise<Result, ResultFailure>
    ) -> Contract<Result, Error> {
        then(on: queue, schedule: .async, block)
    }
    
    @discardableResult
    public func then<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping @Sendable (Value) throws -> Promise<Result, ResultFailure>
    ) -> Contract<Result, Error> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                do {
                    let promise = try block(value)
                    promise.subscribe(
                        on: queue,
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
    @discardableResult
    public func then<Result: Sendable>(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ operation: @escaping @Sendable (Value) async -> Result
    ) -> Contract<Result, Never> {
        let queue = queue ?? self.queue

        let contract = Contract<Result, Never>(queue: self.queue)

        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                Task {
                    defer { finish() }
                    let result = await operation(value)
                    contract.resolve(result)
                }
            },
            onRejected: { _ in },
            onCanceled: { [weak contract] in contract?.cancel() }
        )

        return contract
    }

    @discardableResult
    public func then<Result: Sendable>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) -> Result
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
    public func then<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) -> Promise<Result, ResultFailure>
    ) -> Contract<Result, ResultFailure> {
        then(on: queue, schedule: .async, block)
    }
    
    @discardableResult
    public func then<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping @Sendable (Value) -> Promise<Result, ResultFailure>
    ) -> Contract<Result, ResultFailure> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result, ResultFailure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                let promise = block(value)
                promise.subscribe(
                    on: queue,
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
