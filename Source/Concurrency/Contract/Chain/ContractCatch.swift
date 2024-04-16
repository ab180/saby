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
        _ block: @escaping (Error) throws -> Void
    ) -> Contract<Value, Error> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                do {
                    try block(error)
                    contract.reject(error)
                }
                catch let error {
                    contract.reject(error)
                }
            },
            onCanceled: { [weak contract] in contract?.cancel() }
        )
        
        return contract
    }
    
    @discardableResult
    public func `catch`(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Error) -> Void
    ) -> Contract<Value, Failure> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value, Failure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                block(error)
                contract.reject(error)
            },
            onCanceled: { [weak contract] in contract?.cancel() }
        )
        
        return contract
    }
}
