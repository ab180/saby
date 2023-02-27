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
        _ block: @escaping (Failure) throws -> Value
    ) -> Contract<Value, Error> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value, Error>(queue: self.queue)
        
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
    public func recover<ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) throws -> Promise<Value, ResultFailure>
    ) -> Contract<Value, Error> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value, Error>(queue: self.queue)
        
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

extension Contract {
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) -> Value
    ) -> Contract<Value, Never> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value, Never>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                let result = block(error)
                contract.resolve(result)
            },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    @discardableResult
    public func recover<ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) -> Promise<Value, ResultFailure>
    ) -> Contract<Value, ResultFailure> {
        let queue = queue ?? self.queue
        
        let contract = Contract<Value, ResultFailure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in
                let promise = block(error)
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
            },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}
