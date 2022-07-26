//
//  PromiseRecover.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/12/20.
//

import Foundation

extension Promise {
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Error) throws -> Value
    ) -> Promise<Value> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value>(queue: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: {
                do {
                    let value = try block($0)
                    promiseReturn.resolve(value)
                } catch let error {
                    promiseReturn.reject(error)
                }
            }
        ))
        
        return promiseReturn
    }
    
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Error) throws -> Promise<Value>
    ) -> Promise<Value> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value>(queue: self.queue)
        
        subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: {
                do {
                    try block($0).subscribe(subscriber: Promise<Value>.Subscriber(
                        on: queue,
                        onResolved: { promiseReturn.resolve($0) },
                        onRejected: { promiseReturn.reject($0) }
                    ))
                } catch let error {
                    promiseReturn.reject(error)
                }
            }
        ))
        
        return promiseReturn
    }
}
