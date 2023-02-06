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
        
        let contract = Contract<Value>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { value in
                promise.subscribe(
                    on: queue,
                    onResolved: { _ in contract.resolve(value) },
                    onRejected: { _ in contract.cancel() },
                    onCanceled: { contract.cancel() }
                )
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
