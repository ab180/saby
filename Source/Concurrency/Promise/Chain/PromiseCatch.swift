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
        _ block: @escaping (Error) -> Void
    ) -> Promise<Value> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { block($0); promiseReturn.reject($0) }
        )
        
        return promiseReturn
    }
}
