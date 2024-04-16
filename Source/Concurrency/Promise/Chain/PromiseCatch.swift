//
//  PromiseCatch.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @discardableResult
    public func `catch`(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) throws -> Void
    ) -> Promise<Value, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: {
                do {
                    try block($0)
                    promiseReturn.reject($0)
                }
                catch let error {
                    promiseReturn.reject(error)
                }
            },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    @discardableResult
    public func `catch`(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) -> Void
    ) -> Promise<Value, Failure> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Failure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { block($0); promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}
