//
//  PromiseThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @discardableResult
    public func then(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Void
    ) -> Promise<Void> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Void>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: {
                do {
                    try block($0)
                    promiseReturn.resolve(())
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
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Result
    ) -> Promise<Result> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result>(queue: self.queue)
        
        subscribe(
            on: queue,
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
    public func then<Result>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Value) throws -> Promise<Result>
    ) -> Promise<Result> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: {
                do {
                    let promise = try block($0)
                    promise.subscribe(
                        on: queue,
                        onResolved: { promiseReturn.resolve($0) },
                        onRejected: { promiseReturn.reject($0) },
                        onCanceled: { promiseReturn.cancel() }
                    )
                    self.subscribe(
                        on: queue,
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
