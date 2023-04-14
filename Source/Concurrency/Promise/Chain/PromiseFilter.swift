//
//  PromiseFilter.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/24.
//

import Foundation

extension Promise {
    public func filter(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Bool
    ) -> Promise<Value, Failure> {
        let queue = queue ?? self.queue
        
        let promise = Promise<Value, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                if block(value) { promise.resolve(value) }
            },
            onRejected: { error in promise.reject(error) },
            onCanceled: { promise.cancel() }
        )
        
        return promise
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Result?
    ) -> Promise<Result, Failure> {
        let queue = queue ?? self.queue
        
        let promise = Promise<Result, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                guard let result = block(value) else { return }
                promise.resolve(result)
            },
            onRejected: { error in promise.reject(error) },
            onCanceled: { promise.cancel() }
        )
        
        return promise
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result?, Never>
    ) -> Promise<Result, Failure> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                let promise = block(value)
                promise.subscribe(
                    queue: queue,
                    onResolved: { result in
                        guard let result else { return }
                        promiseReturn.resolve(result)
                    },
                    onRejected: { _ in },
                    onCanceled: { promiseReturn.cancel() }
                )
                self.subscribe(
                    queue: queue,
                    onCanceled: { promise.cancel() }
                )
            },
            onRejected: { error in promiseReturn.reject(error) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
    
    public func filter<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result, Never>?
    ) -> Promise<Result, Failure> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Failure>(queue: queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in
                guard let promise = block(value) else { return }
                promise.subscribe(
                    queue: queue,
                    onResolved: { promiseReturn.resolve($0) },
                    onRejected: { _ in },
                    onCanceled: { promiseReturn.cancel() }
                )
                self.subscribe(
                    queue: queue,
                    onCanceled: { promise.cancel() }
                )
            },
            onRejected: { error in promiseReturn.reject(error) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
}
