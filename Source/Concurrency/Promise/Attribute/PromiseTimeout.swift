//
//  PromiseTimeout.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @discardableResult
    public func timeout(
        on queue: DispatchQueue? = nil,
        _ interval: DispatchTimeInterval
    ) -> Promise<Value, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Error>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        queue.asyncAfter(deadline: .now() + interval) {
            promiseReturn.reject(PromiseError.timeout)
        }
        
        return promiseReturn
    }
}
