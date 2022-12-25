//
//  ContractDelay.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/18.
//

import Foundation

extension Contract {
    public func delay<AnyValue>(
        on queue: DispatchQueue? = nil,
        until promise: Promise<AnyValue>
    ) -> Contract<Value> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(on: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in
                promise.subscribe(
                    on: queue,
                    onResolved: { _ in contract.resolve(value) },
                    onRejected: { contract.reject($0) }
                )
            },
            onRejected: { error in contract.reject(error) }
        ))
        
        return contract
    }
}
