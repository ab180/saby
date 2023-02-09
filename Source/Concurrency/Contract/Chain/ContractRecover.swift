//
//  ContractRecover.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/12/20.
//

import Foundation

extension Contract {
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Error) throws -> Value
    ) -> Contract<Value> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                do {
                    let result = try block(error)
                    contract.resolve(result)
                }
                catch let error {
                    contract.reject(error)
                }
            },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Error) throws -> Promise<Value>
    ) -> Contract<Value> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                do {
                    let promise = try block(error)
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
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
