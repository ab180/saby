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
    ) -> Contract<Value> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(queue: queue)
        
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
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(queue: queue)
        
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
        _ block: @escaping (Value) -> Promise<Result?>
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                let promise = block(value)
                promise.subscribe(
                    queue: queue,
                    onResolved: { result in
                        guard let result else { return }
                        contract.resolve(result)
                    },
                    onRejected: { contract.reject($0) },
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
        _ block: @escaping (Value) -> Promise<Result>?
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                guard let promise = block(value) else { return }
                promise.subscribe(
                    queue: queue,
                    onResolved: { contract.resolve($0) },
                    onRejected: { contract.reject($0) },
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
