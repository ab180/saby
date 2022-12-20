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
        
        let contract = Contract<Value>(on: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                do {
                    let result = try block(error)
                    contract.resolve(result)
                }
                catch let error {
                    contract.reject(error)
                }
            }
        ))
        
        return contract
    }
    
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Error) throws -> Promise<Value>
    ) -> Contract<Value> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value>(on: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                do {
                    try block(error).subscribe(subscriber: Promise.Subscriber(
                        on: queue,
                        onResolved: { contract.resolve($0) },
                        onRejected: { contract.reject($0) }
                    ))
                }
                catch let error {
                    contract.reject(error)
                }
            }
        ))
        
        return contract
    }
}
