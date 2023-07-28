//
//  ContractThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/14.
//

import Foundation

extension Contract {
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
            onCanceled: { contract.cancel() }
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
            onResolved: schedule { [weak self] value, finish in
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
                        onCanceled: { contract.cancel() }
                    )
                    self?.subscribe(
                        queue: queue,
                        onCanceled: { promise.cancel() }
                    )
                }
                catch let error {
                    defer { finish() }
                    contract.reject(error)
                }
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}

extension Contract where Failure == Never {
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
            onCanceled: { contract.cancel() }
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
            onResolved: schedule { [weak self] value, finish in
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
                    onCanceled: { contract.cancel() }
                )
                self?.subscribe(
                    queue: queue,
                    onCanceled: { promise.cancel() }
                )
            },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
