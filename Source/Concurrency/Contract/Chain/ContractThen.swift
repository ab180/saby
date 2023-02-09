//
//  ContractThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/14.
//

import Foundation

extension Contract {
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Result
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                do {
                    let result = try block(value)
                    contract.resolve(result)
                }
                catch let error {
                    contract.reject(error)
                }
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Promise<Result>
    ) -> Contract<Result> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Result>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                do {
                    let promise = try block(value)
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
                }
                catch let error {
                    contract.reject(error)
                }
            },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
