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
        _ block: @escaping (Failure) -> Void
    ) -> Promise<Value, Failure> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Failure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { block($0); promiseReturn.reject($0) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
}
