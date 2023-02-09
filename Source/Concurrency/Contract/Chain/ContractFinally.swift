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
        
        let contract = Contract<Value>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value -> Void in
                block()
                contract.resolve(value)
            },
            onRejected: { error -> Void in
                block()
                contract.reject(error)
            },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
