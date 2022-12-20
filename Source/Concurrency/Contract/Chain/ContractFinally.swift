//
//  ContractFinally.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/18.
//

import Foundation

extension Contract {
    @discardableResult
    public func finally(
        on queue: DispatchQueue? = nil,
        _ block: @escaping () -> Void
    ) -> Contract<Value> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(on: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value -> Void in
                block()
                contract.resolve(value)
            },
            onRejected: { error -> Void in
                block()
                contract.reject(error)
            }
        ))
        
        return contract
    }
}
