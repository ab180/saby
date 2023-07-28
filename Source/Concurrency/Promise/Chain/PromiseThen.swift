//
//  PromiseThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Result
    ) -> Promise<Result, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: {
                do {
                    let value = try block($0)
                    promiseReturn.resolve(value)
                } catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
    
    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Promise<Result, ResultFailure>
    ) -> Promise<Result, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { [weak self] in
                do {
                    let promise = try block($0)
                    promise.subscribe(
                        queue: queue,
                        onResolved: { promiseReturn.resolve($0) },
                        onRejected: { promiseReturn.reject($0) },
                        onCanceled: { promiseReturn.cancel() }
                    )
                    self?.subscribe(
                        queue: queue,
                        onCanceled: { promise.cancel() }
                    )
                } catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
}

extension Promise where Failure == Never {
    @discardableResult
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Result
    ) -> Promise<Result, Never> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Never>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: {
                let value = block($0)
                promiseReturn.resolve(value)
            },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
    
    @discardableResult
    public func then<Result, ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) -> Promise<Result, ResultFailure>
    ) -> Promise<Result, ResultFailure> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, ResultFailure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { [weak self] in
                let promise = block($0)
                promise.subscribe(
                    queue: queue,
                    onResolved: { promiseReturn.resolve($0) },
                    onRejected: { promiseReturn.reject($0) },
                    onCanceled: { promiseReturn.cancel() }
                )
                self?.subscribe(
                    queue: queue,
                    onCanceled: { promise.cancel() }
                )
            },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
}
