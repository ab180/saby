//
//  PromiseFinally.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/07.
//

import Foundation

extension Promise {
    @discardableResult
    public func finally(
        on queue: DispatchQueue? = nil,
        _ block: @escaping () -> Void
    ) -> Promise<Value> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { block(); promiseReturn.resolve($0) },
            onRejected: { block(); promiseReturn.reject($0) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
}
