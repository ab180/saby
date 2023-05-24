//
//  PromiseTimeout.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func timeout(
        on queue: DispatchQueue = .global(),
        _ interval: DispatchTimeInterval
    ) -> Promise<Void, Error> {
        let promise = Promise<Void, Error>(queue: queue)
        
        queue.asyncAfter(deadline: .now() + interval) {
            promise.reject(PromiseError.timeout)
        }
        
        return promise
    }
}

extension Promise {
    @discardableResult
    public func timeout(
        on queue: DispatchQueue? = nil,
        _ interval: DispatchTimeInterval
    ) -> Promise<Value, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        queue.asyncAfter(deadline: .now() + interval) {
            promiseReturn.reject(PromiseError.timeout)
        }
        
        return promiseReturn
    }
}
