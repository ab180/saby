//
//  ContractCatch.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/18.
//

import Foundation

extension Contract {
    @discardableResult
    public func `catch`(on queue: DispatchQueue? = nil,
                        _ block: @escaping (Error) -> Void) -> Contract<Value>
    {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(on: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                block(error)
                contract.reject(error)
            }
        ))
        
        return contract
    }
}
