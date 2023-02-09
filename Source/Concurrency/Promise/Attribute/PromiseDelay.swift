//
//  PromiseDelay.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/08/19.
//

import Foundation

extension Promise where Value == Void {
    public static func delay(
        on queue: DispatchQueue = .global(),
        _ interval: DispatchTimeInterval
    ) -> Promise<Void> {
        let pending = Promise.pending(on: queue)
        
        queue.asyncAfter(deadline: .now() + interval) {
            pending.resolve(())
        }
        
        return pending.promise
    }
}

extension Promise {
    @discardableResult
    public func delay(
        on queue: DispatchQueue? = nil,
        _ interval: DispatchTimeInterval
    ) -> Promise<Value> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value>(queue: self.queue)
        
        self.subscribe(
            queue: queue,
            onResolved: { value in
                queue.asyncAfter(deadline: .now() + interval) {
                    promiseReturn.resolve(value)
                }
            },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { promiseReturn.cancel() }
        )
        
        return promiseReturn
    }
}
