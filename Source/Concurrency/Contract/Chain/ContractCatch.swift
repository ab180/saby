//
//  ContractCatch.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/18.
//

import Foundation

extension Contract {
    @discardableResult
    public func `catch`(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Error) -> Void
    ) -> Contract<Value> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                block(error)
                contract.reject(error)
            },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
