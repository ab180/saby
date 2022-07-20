//
//  PromiseThen.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @discardableResult
    public func then<Result>(on queue: DispatchQueue? = nil,
                             _ block: @escaping (Value) throws -> Result) -> Promise<Result>
    {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result>(on: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: {
                do {
                    let value = try block($0)
                    promiseReturn.resolve(value)
                } catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) }
        ))
        
        return promiseReturn
    }
    
    @discardableResult
    public func then<Result>(on queue: DispatchQueue? = nil,
                             _ block: @escaping (Value) throws -> Promise<Result>) -> Promise<Result>
    {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Result>(on: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: {
                do {
                    try block($0).subscribe(subscriber: Promise<Result>.Subscriber(
                        on: queue,
                        onResolved: { promiseReturn.resolve($0) },
                        onRejected: { promiseReturn.reject($0) }
                    ))
                } catch let error {
                    promiseReturn.reject(error)
                }
            },
            onRejected: { promiseReturn.reject($0) }
        ))
        
        return promiseReturn
    }
}
