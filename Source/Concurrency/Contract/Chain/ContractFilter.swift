//
//  ContractFilter.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/24.
//

import Foundation

extension Contract {
    public func filter(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Bool
    ) -> Contract<Value, Failure> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                if block(value) { contract.resolve(value) }
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Result?
    ) -> Contract<Result, Failure> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                guard let result = block(value) else { return }
                contract.resolve(result)
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result?, Never>
    ) -> Contract<Result, Failure> {
        filter(on: queue, schedule: .async, block)
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping (Value) -> Promise<Result?, Never>
    ) -> Contract<Result, Failure> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                let promise = block(value)
                promise.subscribe(
                    queue: queue,
                    onResolved: { result in
                        defer { finish() }
                        guard let result else { return }
                        contract.resolve(result)
                    },
                    onRejected: { _ in },
                    onCanceled: { contract.cancel() }
                )
                self.subscribe(
                    queue: queue,
                    onCanceled: { promise.cancel() }
                )
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result, Never>?
    ) -> Contract<Result, Failure> {
        filter(on: queue, schedule: .async, block)
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        schedule: ContractSchedule = .async,
        _ block: @escaping (Value) -> Promise<Result, Never>?
    ) -> Contract<Result, Failure> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: schedule { value, finish in
                guard let promise = block(value) else { return }
                promise.subscribe(
                    queue: queue,
                    onResolved: {
                        defer { finish() }
                        contract.resolve($0)
                    },
                    onRejected: { _ in },
                    onCanceled: { contract.cancel() }
                )
                self.subscribe(
                    queue: queue,
                    onCanceled: { promise.cancel() }
                )
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
