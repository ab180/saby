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
        let (promise, resolve, _) = Promise.pending(on: queue)
        
        queue.asyncAfter(deadline: .now() + interval) {
            resolve(())
        }
        
        return promise
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
        
        self.subscribe(subscriber: Subscriber(
            on: queue,
            onResolved: { value in
                queue.asyncAfter(deadline: .now() + interval) {
                    promiseReturn.resolve(value)
                }
            },
            onRejected: { promiseReturn.reject($0) }
        ))
        
        return promiseReturn
    }
}
