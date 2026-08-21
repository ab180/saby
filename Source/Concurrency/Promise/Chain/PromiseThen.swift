//
//  PromiseThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @discardableResult
    public func then<Result: Sendable>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) throws -> Result
    ) -> Promise<Result, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Error>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: {
                do {
                    let value = try block($0)
                    promiseReturn.resolve(value)
                }
                catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    @discardableResult
    public func then<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) throws -> Promise<Result, ResultFailure>
    ) -> Promise<Result, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Error>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: {
                do {
                    let promise = try block($0)
                    promise.subscribe(
                        on: queue,
                        onResolved: { promiseReturn.resolve($0) },
                        onRejected: { promiseReturn.reject($0) },
                        onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
                    )
                }
                catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}

extension Promise where Failure == Never {
    @discardableResult
    public func then<Result: Sendable>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) -> Result
    ) -> Promise<Result, Never> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, Never>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: {
                let value = block($0)
                promiseReturn.resolve(value)
            },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    @discardableResult
    public func then<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        on queue: DispatchQueue? = nil,
        _ block: @escaping @Sendable (Value) -> Promise<Result, ResultFailure>
    ) -> Promise<Result, ResultFailure> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result, ResultFailure>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: {
                let promise = block($0)
                promise.subscribe(
                    on: queue,
                    onResolved: { promiseReturn.resolve($0) },
                    onRejected: { promiseReturn.reject($0) },
                    onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
                )
            },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}
