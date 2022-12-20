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
        
        let contract = Contract<Value>(on: queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in
                if block(value) { contract.resolve(value) }
            },
            onRejected: { error in contract.reject(error) }
        ))
        
        return contract
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Result?
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(on: queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in
                guard let result = block(value) else { return }
                contract.resolve(result)
            },
            onRejected: { error in contract.reject(error) }
        ))
        
        return contract
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result?>
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(on: queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in
                block(value).subscribe(subscriber: Promise.Subscriber(
                    on: queue,
                    onResolved: { result in
                        guard let result else { return }
                        contract.resolve(result)
                    },
                    onRejected: { contract.reject($0) }
                ))
            },
            onRejected: { error in contract.reject(error) }
        ))
        
        return contract
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result>?
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(on: queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in
                guard let valuePromise = block(value) else { return }
                valuePromise.subscribe(subscriber: Promise.Subscriber(
                    on: queue,
                    onResolved: { contract.resolve($0) },
                    onRejected: { contract.reject($0) }
                ))
            },
            onRejected: { error in contract.reject(error) }
        ))
        
        return contract
    }
}
